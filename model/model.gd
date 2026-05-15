class_name Model
extends Object

const TERRAIN_COUNTS := {
	Terrain.HILL: 3,
	Terrain.FOREST: 4,
	Terrain.MOUNTAIN: 3,
	Terrain.FIELD: 4,
	Terrain.PASTURE: 4,
	Terrain.DESERT: 1,
}

const TERRAIN_TO_RESOURCE : Dictionary[Terrain, ResourceTypes] = {
	Terrain.HILL: ResourceTypes.BRICK,
	Terrain.FOREST: ResourceTypes.WOOD,
	Terrain.FIELD: ResourceTypes.WHEAT,
	Terrain.PASTURE: ResourceTypes.WOOL,
	Terrain.MOUNTAIN: ResourceTypes.ROCK,	
	Terrain.DESERT: ResourceTypes.NONE,
	Terrain.WATER: ResourceTypes.NONE
}

enum Terrain {
	HILL,
	FOREST,
	MOUNTAIN,
	FIELD,
	PASTURE,
	DESERT,
	WATER
}

enum ResourceTypes {
	BRICK,
	WOOD,
	WHEAT,
	WOOL,
	ROCK,	
	NONE,
	ANY
}

enum ActionCardTypes {
	SOLDIER,
	BUILD_ROAD,
	PLENTY,
	MONOPOLY,
	VICTORY_POINTS
}

const CARD_DISTRIBUTION : Dictionary[Model.ActionCardTypes, int] = {
	ActionCardTypes.SOLDIER: 56,
	ActionCardTypes.BUILD_ROAD: 20,
	ActionCardTypes.PLENTY: 8,
	ActionCardTypes.MONOPOLY: 8,
	ActionCardTypes.VICTORY_POINTS: 8,
}

enum GamePhase {
	NOT_STARTED,
	SETUP_FORWARD_HOUSE,
	SETUP_FORWARD_ROAD,
	SETUP_REVERSE_HOUSE,
	SETUP_REVERSE_ROAD,
	MOVE_PIRATE,
	INIT_DISCARD,
	DURING_DISCARD,
	STEAL_RESOURCES,
	MAIN,
	YEAR_OF_PLENTY,
	MONOPOLY,
	ROAD_BUILDING,
	SOLDIER,
	GAME_OVER,
}

static var COSTS = {
	"house" : Wallet.new([ResourceTypes.WOOD, ResourceTypes.BRICK, ResourceTypes.WOOL, ResourceTypes.WHEAT]),
	"city" :  Wallet.new([ResourceTypes.WHEAT, ResourceTypes.WHEAT, ResourceTypes.WHEAT, ResourceTypes.ROCK, ResourceTypes.ROCK]),
	"road" :  Wallet.new([ResourceTypes.WOOD, ResourceTypes.BRICK,]),
	"card" :  Wallet.new([ResourceTypes.WOOL, ResourceTypes.WHEAT, ResourceTypes.ROCK])
}


var _player_records: Dictionary[int, PlayerRecord] = {}

var _current_player: int = 0
var _game_phase: GamePhase = GamePhase.NOT_STARTED
var _pirate: Axial
var _hexes: AxialSet = AxialSet.new()
var _corners: AxialSet = AxialSet.new()
var _edges: AxialEdgeSet = AxialEdgeSet.new()
var _players_discarded: Dictionary[int, bool] # player_id -> needs to discard

var _hex_data: Dictionary[String, HexData] = {}

var _houses: Dictionary[String, int] = {}
var _cities: Dictionary[String, int] = {}
var _roads: Dictionary[String, int] = {}

var _houses_mirror: Dictionary[int, Array] = {}
var _cities_mirror: Dictionary[int, Array] = {}
var _roads_mirror: Dictionary[int, Array] = {}

var _bank: Dictionary[int, Wallet] = {}
var _exchange_rate: Dictionary[int, Wallet] = {}
var _owned_action_cards: Dictionary[int, ActionCardWallet] = {}
var _playable_action_cards: Dictionary[int, ActionCardWallet] = {}

var _ports: Dictionary[String, ResourceTypes] = {}
var _longest_road:int = -1
var _largest_army:int = -1

var _dice: Array[int] = [1, 1]


func all_hexes() -> AxialSet:               return self._hexes.duplicate(true)
func all_corners() -> AxialSet:             return self._corners.duplicate(true)
func all_edges() -> AxialEdgeSet:           return self._edges.duplicate(true)
func get_pirate() -> Axial:                 return self._pirate.duplicate()
func get_current_player() -> int:           return self._current_player
func get_current_phase() -> GamePhase:      return self._game_phase
func get_port(cax: Axial) -> ResourceTypes: return self._ports.get(cax.key(), ResourceTypes.NONE)
func get_army(id: int) -> int:              return self._player_records[id].soldiers
func get_victory_points(id: int) -> int:    return self._player_records[id].victory_points
func get_dice() -> Array[int]:              return self._dice.duplicate()
func get_exchange_rate(id: int, r: ResourceTypes) -> int: return self._exchange_rate[id].get_resource(r)
func get_bank(id: int) -> Wallet: return self._bank[id].duplicate()
func get_owned_action_cards(id: int) -> ActionCardWallet: return self._owned_action_cards[id]
func get_playable_action_cards(id: int) -> ActionCardWallet: return self._playable_action_cards[id]
func count_resources(id: int) -> int: return self._bank[id].count_resources()
func get_discarded() -> Dictionary[int, bool]: return self._players_discarded.duplicate()
func get_longest_road() -> int: return self._longest_road 
func get_largest_army() -> int: return self._largest_army
func get_player_record(id: int) -> PlayerRecord: return self._player_records[id].duplicate()
func player_count() -> int: return self._player_records.size() # todo move all player counts to this

func has_resources(id: int, wallet: Wallet) -> bool: 
	return self._bank[id].has_resources(wallet)


func get_owner(ax: Axial) -> int:
	if self._cities.has(ax.key()):
		return self._cities[ax.key()]
	if self._houses.has(ax.key()):
		return self._houses[ax.key()]
	return -1


func get_roads(id: int = -1) -> AxialEdgeSet:
	var aset := AxialEdgeSet.new()

	if id == -1:
		for p in range(4):
			aset.add_all(self.get_roads(p))
	else:
		aset.add_all(self._roads_mirror[id])

	return aset	


func get_houses(id: int = -1) -> AxialSet:
	var aset := AxialSet.new()

	if id == -1:
		for p in range(4):
			aset.add_all(self.get_houses(p))
	else:
		aset.add_all(self._houses_mirror[id])

	return aset	


func get_cities(id: int = -1) -> AxialSet:
	var aset := AxialSet.new()

	if id == -1:
		for p in range(4):
			aset.add_all(self.get_cities(p))
	else:
		aset.add_all(self._cities_mirror[id])

	return aset


func get_all_buildings(id: int = -1) -> AxialSet:
	var result := AxialSet.new()

	if id == -1:
		for p in range(4):
			result.add_all(self.get_houses(p))
			result.add_all(self.get_cities(p))
	else:
		result.add_all(self.get_houses(id))
		result.add_all(self.get_cities(id))
	return result


func get_hex_data(hex: Axial) -> HexData:
	var data = self._hex_data.get(hex.key(), null)
	if data and hex.equals(self._pirate):
		data.pirate = true
	else:
		data.pirate = false
	return data


func do_end_turn() -> void:
	self._current_player = (self._current_player + 1) % self.player_count()		
	EventBus.current_player_updated.emit(self._current_player)

	var owned = self._owned_action_cards[self._current_player]
	var playable = self._playable_action_cards[self._current_player]
	owned.copy_from(playable)
	EventBus.action_cards_updated.emit(self._current_player, owned, playable)


func do_set_dice(d1: int, d2:int) -> void:
	self._dice[0] = d1
	self._dice[1] = d2
	EventBus.dice_set.emit(d1, d2)


func do_set_house(id: int, ax: Axial) -> void:	
	self._houses[ax.key()] = id
	self._houses_mirror[id].append(ax)
	self.do_add_victory_point(id)
	EventBus.house_added.emit(id, ax)
	self._calc_longest_road()


func do_set_city(id: int, ax: Axial) -> void:
	self._cities[ax.key()] = id
	self._cities_mirror[id].append(ax)
	self._houses_mirror[id].erase(ax)
	self.do_add_victory_point(id)
	EventBus.city_added.emit(id, ax)


func do_set_road(id: int, edge: AxialEdge) -> void:
	self._roads[edge.key()] = id
	self._roads_mirror[id].append(edge)
	EventBus.road_added.emit(id, edge)
	self._calc_longest_road()


func _calc_longest_road() -> void:
	# calculate all road lengths
	for pid in range(Game.player_count):
		var length := RoadCalculator.calculate_longest_road(pid, self)
		self._player_records[pid].roads = length

	# find longest >= 5, favouring current holder on tie
	var best_length := 0
	var best_id := -1

	for pid in range(Game.player_count):
		var length: int = self._player_records[pid].roads
		if length < 5:
			continue
		if length > best_length or (length == best_length and pid == self._longest_road):
			best_length = length
			best_id = pid

	if best_id != self._longest_road:
		self._set_longest_road(best_id)


func _set_longest_road(id: int) -> void:
	if self._longest_road != -1:
		self._player_records[self._longest_road].victory_points -= 2

	self._longest_road = id
	self._player_records[id].victory_points += 2
	EventBus.update_longest_road.emit(id)


func do_add_resources(id: int, resources: Wallet) -> void:
	self._bank[id].add_resources(resources)
	self._player_records[id].resources = self._bank[id].count_resources()
	EventBus.resources_updated.emit(id, self._bank[id].duplicate())


func do_remove_resources(id: int, resources:Wallet) -> void:
	self._bank[id].remove_resources(resources)
	self._player_records[id].resources = self._bank[id].count_resources()
	EventBus.resources_updated.emit(id, self._bank[id].duplicate())


func do_add_action_card(id: int, card: ActionCardTypes) -> void:
	self._owned_action_cards[id].add_card(card)
	var owned := self._owned_action_cards[id].duplicate()
	var playable := self._playable_action_cards[id].duplicate()
	EventBus.action_cards_updated.emit(id, owned, playable)


func do_remove_action_card(id: int, card) -> void:
	self._owned_action_cards[id].remove_card(card)
	var owned := self._owned_action_cards[id].duplicate()
	var playable := self._playable_action_cards[id].duplicate()
	EventBus.action_cards_updated.emit(id, owned, playable)


func do_update_phase(phase: GamePhase) -> void:
	self._game_phase = phase
	EventBus.current_phase_updated.emit(phase)


func do_update_player(id: int) -> void:
	self._current_player = id
	EventBus.current_player_updated.emit(id)


func do_set_exchange_rate(id: int, resource, value: int) -> void:
	self._exchange_rate[id].set_resource(resource, value)
	EventBus.exchange_rate_set.emit(id, resource, value)


func do_set_pirate(ax: Axial) -> void:
	self._pirate = ax.duplicate()
	EventBus.pirate_set.emit(ax.duplicate())


func do_add_victory_point(id: int, amt: int = 1) -> void:
	self._player_records[id].victory_points += amt


func do_remove_victory_point(id: int, amt: int = 1) -> void:
	self._player_records[id].victory_points -= amt


func do_add_soldier(id: int) -> void:
	self._player_records[id].soldiers += 1

	if self._player_records[id].soldiers < 3: return

	if self._largest_army != -1:
		self._player_records[self._largest_army].victory_points -= 2

	self._largest_army = id
	self._player_records[id].victory_points += 2
	EventBus.update_largest_army.emit(id)


func do_discard(id: int, wallet: Wallet) -> void:
	self.do_remove_resources(id, wallet)
	self._players_discarded[id] = false


func reset_discard() -> void:
	for id in Game.player_count:
		self._players_discarded[id] = false


func set_discard(id: int, value: bool) -> void:	
	self._players_discarded[id] = value


func _init(names: Array[String]) -> void:
	self._place_tiles()
	self._place_water()
	self._place_ports()
	self.reset_discard()

	for i in range(Game.player_count):
		self._bank[i] = Wallet.new()
		self._exchange_rate[i] = Wallet.new()
		self._exchange_rate[i].set_all(4)
		self._owned_action_cards[i] = ActionCardWallet.new()
		self._playable_action_cards[i] = ActionCardWallet.new()
		self._houses_mirror[i] = [] as Array[Axial]
		self._cities_mirror[i] = [] as Array[Axial]
		self._roads_mirror[i] = [] as Array[AxialEdge]	
		self._player_records[i] = PlayerRecord.new(i, names[i])

# populates (non-wate) hexes, corners, edges
# populate hexdata with hex, terrain, resource
# set pirate
func _place_tiles() -> void:
	var terrain_bag := self._fill_terrain_bag()
	var number_bag: Array[int] = [2, 3, 3, 4, 4, 5, 5, 6, 6, 8, 8, 9, 9, 10, 10, 11, 11, 12]
	number_bag.shuffle()

	var neighbors := Axial.zero().neighbors()
	var distant_neighbors := neighbors.map(Axial.neighbors_of)

	self._hexes.add_item(Axial.zero())
	self._hexes.add_all(neighbors)
	self._hexes.add_all(distant_neighbors)
	self._corners = self._hexes.map(Axial.corners_of)
	self._edges = self._hexes.edge_map(Axial.edges_of)

	for hex in self._hexes:
		var hex_data = HexData.new()
		self._hex_data[hex.key()] = hex_data

		hex_data.axial    = hex
		hex_data.terrain  = terrain_bag.pop_front()
		hex_data.pirate   = hex_data.terrain == Terrain.DESERT
		hex_data.resource = TERRAIN_TO_RESOURCE[hex_data.terrain]

		if hex_data.terrain == Terrain.DESERT: 
			self._pirate = hex
		else: 
			hex_data.number = number_bag.pop_front()


func _place_ports() -> void:
	self._place_port(Axial.new(0, -3, 3), 2, Model.ResourceTypes.ANY)
	self._place_port(Axial.new(0, -3, 3), 3, Model.ResourceTypes.ANY)

	self._place_port(Axial.new(2, -3, 1), 3, Model.ResourceTypes.BRICK)
	self._place_port(Axial.new(2, -3, 1), 4, Model.ResourceTypes.BRICK)

	self._place_port(Axial.new(3, -2, -1), 3, Model.ResourceTypes.ANY)
	self._place_port(Axial.new(3, -2, -1), 4, Model.ResourceTypes.ANY)

	self._place_port(Axial.new(3, 0, -3), 4, Model.ResourceTypes.WOOD)
	self._place_port(Axial.new(3, 0, -3), 5, Model.ResourceTypes.WOOD)

	self._place_port(Axial.new(1, 2, -3), 5, Model.ResourceTypes.WOOL)
	self._place_port(Axial.new(1, 2, -3), 0, Model.ResourceTypes.WOOL)

	self._place_port(Axial.new(-1, 3, -2), 5, Model.ResourceTypes.ROCK)
	self._place_port(Axial.new(-1, 3, -2), 0, Model.ResourceTypes.ROCK)

	self._place_port(Axial.new(-3, 3, 0), 0, Model.ResourceTypes.ANY)
	self._place_port(Axial.new(-3, 3, 0), 1, Model.ResourceTypes.ANY)

	self._place_port(Axial.new(-3, 1, 2), 1, Model.ResourceTypes.WHEAT)
	self._place_port(Axial.new(-3, 1, 2), 2, Model.ResourceTypes.WHEAT)

	self._place_port(Axial.new(-2, -1, 3), 1, Model.ResourceTypes.ANY)
	self._place_port(Axial.new(-2, -1, 3), 2, Model.ResourceTypes.ANY)


# populate ports
# populate hexdata with ports & port type
func _place_port(hex: Axial, corner: int, value: ResourceTypes) -> void:
	var cax = hex.corners().to_array()[corner]
	self._ports[cax.key()] = value
	self._hex_data[hex.key()].ports.add_item(cax.duplicate())
	self._hex_data[hex.key()].port_type = value


# populates water hexes and hexdata
func _place_water() -> void:
	var water := self._hexes.map(Axial.neighbors_of)
	water = water.difference(self._hexes)

	for hex in water:
		self._hex_data[hex.key()] = HexData.new()
		self._hex_data[hex.key()].axial = hex
		self._hex_data[hex.key()].terrain = Terrain.WATER

	self._hexes.add_all(water)


func _fill_terrain_bag() -> Array[Terrain]:
	var terrain_bag: Array[Terrain] = []

	for terrain in TERRAIN_COUNTS:
		for i in TERRAIN_COUNTS[terrain]:
			terrain_bag.append(terrain)
	terrain_bag.shuffle()

	return terrain_bag
