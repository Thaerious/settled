# filename: python/convert_model.py
import random

from catanatron.game import Game
from catanatron.state import PLAYER_INITIAL_STATE
from catanatron.models.player import Color, RandomPlayer
from catanatron.models.map import CatanMap, BASE_MAP_TEMPLATE, initialize_tiles, LandTile, Port
from catanatron.models.actions import generate_playable_actions
from catanatron.models.enums import ActionPrompt
from catanatron.state_functions import (
	build_settlement,
	build_road,
	build_city,
	player_freqdeck_add,
	player_key,
	play_dev_card,
	maintain_longest_road,
)


# catanatron resources/dev cards are plain strings, not enum classes
# (verified against installed package — Resource.WOOD etc. don't exist)
RESOURCE_MAP = {
	"WOOD":  "WOOD",
	"BRICK": "BRICK",
	"WOOL":  "SHEEP",
	"WHEAT": "WHEAT",
	"ROCK":  "ORE",
}

DEV_CARD_MAP = {
	"SOLDIER":        "KNIGHT",
	"MONOPOLY":       "MONOPOLY",
	"PLENTY":         "YEAR_OF_PLENTY",
	"BUILD_ROAD":     "ROAD_BUILDING",
	"VICTORY_POINTS": "VICTORY_POINT",
}

# Settled SetupPhase -> catanatron initial-build prompt
SETUP_PROMPTS = {
	"HOUSE1": ActionPrompt.BUILD_INITIAL_SETTLEMENT,
	"HOUSE2": ActionPrompt.BUILD_INITIAL_SETTLEMENT,
	"ROAD1":  ActionPrompt.BUILD_INITIAL_ROAD,
	"ROAD2":  ActionPrompt.BUILD_INITIAL_ROAD,
}

# Settled player id 0..3 -> catanatron seat color. Arbitrary but fixed.
COLORS = [Color.RED, Color.BLUE, Color.WHITE, Color.ORANGE]

# port of Axial.CORNERS — hex-to-corner offsets, used to derive which
# hexes touch a given corner without needing Settled's Axial class here
CORNER_OFFSETS = [
	(1, 0, 1),
	(1, 0, 0),
	(1, 1, 0),
	(0, 1, 0),
	(0, 1, 1),
	(0, 0, 1),
]


def convert_model(data) -> Game:
	catan_map = _build_map(data["hex_data"])
	node_lookup = _build_node_lookup(catan_map, data["hex_data"])

	players = [RandomPlayer(COLORS[i]) for i in range(4)]
	game = Game(players, catan_map=catan_map, seed=0)
	state = game.state

	# normal init shuffles seating; force Settled id order (P0 = COLORS[0], ...)
	state.players = players
	state.colors = tuple(COLORS)
	state.color_to_index = {c: i for i, c in enumerate(COLORS)}

	_place_buildings(state, data["houses"], data["cities"], data["initial_houses"], node_lookup)
	_place_roads(state, data["roads"], node_lookup)
	_load_hands(state, data["bank"])
	_load_bank(state, data["remaining_resources"])
	_load_dev_decks(state, data)
	_load_turn_state(state, data["state"])
	_load_robber(state, data["hex_data"])

	state.playable_actions = generate_playable_actions(state)
	game.id = "loaded-from-settled"
	return game


def _build_map(hex_data: dict) -> CatanMap:
	# Node/edge id assignment only depends on tile adjacency (fixed
	# topology), never on which resource/number lands where — so any
	# shuffle here is fine, we just overwrite resource/number/port after.
	tiles = initialize_tiles(BASE_MAP_TEMPLATE)

	for coord, tile in tiles.items():
		key = "%d,%d,%d" % coord
		settled_tile = hex_data[key]

		if isinstance(tile, LandTile):
			terrain = settled_tile["terrain"]
			tile.resource = None if terrain == "DESERT" else RESOURCE_MAP[settled_tile["resource"]]
			tile.number = None if settled_tile["number"] == -1 else settled_tile["number"]
		elif isinstance(tile, Port):
			port_type = settled_tile["port_type"]
			tile.resource = None if port_type in ("NONE", "ANY") else RESOURCE_MAP[port_type]
		# Water tiles: nothing to set

	return CatanMap.from_tiles(tiles)


def _build_node_lookup(catan_map: CatanMap, hex_data: dict) -> dict:
	# Match corners structurally: a corner is uniquely identified by the
	# SET of hex coordinates touching it. Since cube coords map 1:1
	# between Settled and catanatron, matching that set is enough —
	# no need to reverse-engineer catanatron's NodeRef orientation.
	all_hex_coords = {tuple(int(x) for x in k.split(",")) for k in hex_data.keys()}

	# catanatron side: node_id -> set of tile coords touching it
	node_tile_coords: dict = {}
	for coord, tile in catan_map.tiles.items():
		for node_id in tile.nodes.values():
			node_tile_coords.setdefault(node_id, set()).add(coord)
	signature_to_node = {frozenset(v): k for k, v in node_tile_coords.items()}

	# Settled side: every possible corner, derived from each hex's 6 corners
	corners = set()
	for (q, r, s) in all_hex_coords:
		for oq, orr, os_ in CORNER_OFFSETS:
			corners.add((q + oq, r + orr, s + os_))

	node_lookup = {}
	unmatched = []
	for (cq, cr, cs) in corners:
		sig = set()
		for oq, orr, os_ in CORNER_OFFSETS:
			hex_coord = (cq - oq, cr - orr, cs - os_)
			if hex_coord in all_hex_coords:
				sig.add(hex_coord)
		sig = frozenset(sig)

		node_id = signature_to_node.get(sig)
		if node_id is None:
			unmatched.append((cq, cr, cs))
			continue
		node_lookup["%d,%d,%d" % (cq, cr, cs)] = node_id

	if unmatched:
		print(f"WARNING: {len(unmatched)} corners had no catanatron node match: {unmatched[:5]}...")

	return node_lookup


def _edge_key_to_corners(key: str):
	# port of AxialEdge.from_key — edge key is the midpoint of its two corners
	q, r, s = (float(x) for x in key.split(","))
	if round(q) != q:
		return (int(q + 0.5), int(r), int(s)), (int(q - 0.5), int(r), int(s))
	elif round(r) != r:
		return (int(q), int(r + 0.5), int(s)), (int(q), int(r - 0.5), int(s))
	else:
		return (int(q), int(r), int(s + 0.5)), (int(q), int(r), int(s - 0.5))


def _place_buildings(state, houses: dict, cities: dict, initial_houses: dict, node_lookup: dict) -> None:
	# Initial houses go first, in placement order: during setup catanatron's
	# initial_road_possibilities() only offers roads next to the LAST
	# settlement appended to buildings_by_color[color][SETTLEMENT].
	ordered = []
	for pid_str, axials in initial_houses.items():
		ordered += [(ax, int(pid_str)) for ax in axials]
	seen = {ax for ax, _ in ordered}
	ordered += [(ax, pid) for ax, pid in houses.items() if ax not in seen]

	# Model.do_set_city() (pre-fix) never removed the stale entry from the
	# flat _houses dict, only from _houses_mirror — so a city's axial could
	# also still be sitting in `houses`. Cities win regardless.
	for axial_key, pid in ordered:
		if axial_key in cities: continue
		if axial_key not in houses: continue  # initial house no longer a house
		color = COLORS[pid]
		node_id = node_lookup[axial_key]
		# initial_build_phase=True bypasses the road-connectivity check —
		# we're loading pre-existing state, not simulating a legal build
		state.board.build_settlement(color, node_id, initial_build_phase=True)
		build_settlement(state, color, node_id, is_free=True)

	for axial_key, pid in cities.items():
		color = COLORS[pid]
		node_id = node_lookup[axial_key]
		# board.build_city() requires a SETTLEMENT already registered at
		# this node, so place one first. state_functions.build_city() has
		# no is_free flag and always deducts 2 WHEAT + 3 ORE — refund it
		# manually since we're loading a pre-existing city, not paying for one.
		state.board.build_settlement(color, node_id, initial_build_phase=True)
		build_settlement(state, color, node_id, is_free=True)
		state.board.build_city(color, node_id)
		build_city(state, color, node_id)
		key = player_key(state, color)
		state.player_state[f"{key}_WHEAT_IN_HAND"] += 2
		state.player_state[f"{key}_ORE_IN_HAND"] += 3


def _place_roads(state, roads: dict, node_lookup: dict) -> None:
	# board.build_road() validates that the edge connects to the player's
	# existing pieces and raises otherwise. JSON dict order won't generally
	# respect connectivity, so place in multiple passes: whatever's
	# reachable gets placed, repeat until nothing more can be placed.
	pending = []
	for edge_key, pid in roads.items():
		a, b = _edge_key_to_corners(edge_key)
		edge = (node_lookup["%d,%d,%d" % a], node_lookup["%d,%d,%d" % b])
		pending.append((COLORS[pid], edge))

	while pending:
		placed = []
		remaining = []
		for color, edge in pending:
			try:
				result = state.board.build_road(color, edge)
			except ValueError:
				remaining.append((color, edge))
				continue
			build_road(state, color, edge, is_free=True)
			previous_road_color, road_color, road_lengths = result
			maintain_longest_road(state, previous_road_color, road_color, road_lengths)
			placed.append((color, edge))

		if not placed:
			# genuinely disconnected from any settlement — a real data bug
			raise RuntimeError(f"{len(remaining)} roads disconnected from any settlement: {remaining}")
		pending = remaining


def _load_hands(state, bank: dict) -> None:
	for pid_str, wallet in bank.items():
		color = COLORS[int(pid_str)]
		# order must match catanatron's freqdeck: [WOOD, BRICK, SHEEP, WHEAT, ORE]
		freqdeck = [
			wallet["WOOD"], wallet["BRICK"], wallet["WOOL"], wallet["WHEAT"], wallet["ROCK"],
		]
		player_freqdeck_add(state, color, freqdeck)


def _load_bank(state, remaining_resources: dict) -> None:
	state.resource_freqdeck = [
		remaining_resources["WOOD"],
		remaining_resources["BRICK"],
		remaining_resources["WOOL"],
		remaining_resources["WHEAT"],
		remaining_resources["ROCK"],
	]


def _load_dev_decks(state, data: dict) -> None:
	# undrawn dev card deck
	deck = []
	for name, count in data["remaining_action_cards"].items():
		deck += [DEV_CARD_MAP[name]] * count
	random.shuffle(deck)
	state.development_listdeck = deck

	# cards currently in each player's hand
	for pid_str, cards in data["owned_action_cards"].items():
		color = COLORS[int(pid_str)]
		key = player_key(state, color)
		for name, count in cards.items():
			if count <= 0: continue
			dev_card = DEV_CARD_MAP[name]
			state.player_state[f"{key}_{dev_card}_IN_HAND"] += count
			if dev_card == "VICTORY_POINT":
				state.player_state[f"{key}_ACTUAL_VICTORY_POINTS"] += count

	# soldiers already played (Settled tracks this as a count on
	# PlayerRecord, not as cards sitting in a "played" pile) -> draw +
	# immediately play that many KNIGHTs so PLAYED_KNIGHT and largest-army
	# bookkeeping come out right, same as the real engine's play_dev_card()
	for pid_str, record in data["player_records"].items():
		color = COLORS[int(pid_str)]
		soldiers = record["soldiers"]
		if soldiers <= 0: continue
		key = player_key(state, color)
		state.player_state[f"{key}_KNIGHT_IN_HAND"] += soldiers
		for _ in range(soldiers):
			play_dev_card(state, color, "KNIGHT")


def _load_turn_state(state, s: dict) -> None:
	pid = s["current_player"]
	state.current_player_index = pid
	state.current_turn_index = pid

	phase = s["game_phase"]
	state.is_initial_build_phase = phase == "SETUP"

	# Settled's PRE_ROLL/SETUP/NOT_STARTED are the only phases before the
	# dice have been rolled this turn; everything else implies HAS_ROLLED.
	# generate_playable_actions() checks this and will only offer ROLL
	# until it's True, so getting this wrong silently starves the bot.
	key = player_key(state, COLORS[pid])
	state.player_state[f"{key}_HAS_ROLLED"] = phase not in ("PRE_ROLL", "SETUP", "NOT_STARTED")

	state.is_discarding    = phase == "DISCARD"
	state.is_moving_knight = phase == "MOVE_PIRATE"
	state.is_road_building = phase == "ROAD_BUILDING"
	state.free_roads_available = s["road_building"] if state.is_road_building else 0

	if state.is_initial_build_phase:
		# snake-draft direction is derived by catanatron from total
		# settlement count, so only the prompt needs setting here
		sp = s.get("setup_phase", "NONE")
		if sp not in SETUP_PROMPTS:
			raise ValueError(f"game_phase SETUP but setup_phase={sp!r}")
		state.current_prompt = SETUP_PROMPTS[sp]
	elif state.is_discarding:
		state.current_prompt = ActionPrompt.DISCARD
	elif state.is_moving_knight:
		state.current_prompt = ActionPrompt.MOVE_ROBBER
	else:
		state.current_prompt = ActionPrompt.PLAY_TURN
	# NOTE: Settled's STEAL_RESOURCES phase has no direct catanatron
	# equivalent here and falls through to PLAY_TURN — unverified against
	# a real mid-steal save.


def _load_robber(state, hex_data: dict) -> None:
	for coord_key, tile in hex_data.items():
		if tile["pirate"]:
			q, r, s = coord_key.split(",")
			state.board.robber_coordinate = (int(q), int(r), int(s))
			return