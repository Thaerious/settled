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
	SETUP,
	MOVE_PIRATE,
	DISCARD,
	STEAL_RESOURCES,
	MAIN,
	YEAR_OF_PLENTY,
	MONOPOLY,
	ROAD_BUILDING,
	SOLDIER,
	GAME_OVER,
	ALL,
	NONE,
	PRE_ROLL
}

enum PlacementPhase{
	HOUSE1,
	HOUSE2,
	ROAD1,
	ROAD2,
	NONE
}

static var COSTS = {
	"house" : Wallet.new([ResourceTypes.WOOD, ResourceTypes.BRICK, ResourceTypes.WOOL, ResourceTypes.WHEAT]),
	"city" :  Wallet.new([ResourceTypes.WHEAT, ResourceTypes.WHEAT, ResourceTypes.WHEAT, ResourceTypes.ROCK, ResourceTypes.ROCK]),
	"road" :  Wallet.new([ResourceTypes.WOOD, ResourceTypes.BRICK,]),
	"card" :  Wallet.new([ResourceTypes.WOOL, ResourceTypes.WHEAT, ResourceTypes.ROCK])
}

const INT_MAX = 9223372036854775807 

var _current_player: int = 0  						# the current active player
var _game_phase: GamePhase = GamePhase.NOT_STARTED  # the currnet phase
var _longest_road:int = -1                          # player who owns longest road (-1 is none)
var _largest_army:int = -1                          # player with the largest army (-1 is none)
var _pirate: Axial                                  # the axial the pirate is one (starts on desert)

var _player_records: Dictionary[int, PlayerRecord] = {}  # player information map
var _hex_data: Dictionary[String, HexData] = {}          # hex (tile) data map for all tiles (incl water)
var _houses_mirror: Dictionary[int, AxialSet] = {}       # map of player id -> owned houses
var _cities_mirror: Dictionary[int, AxialSet] = {}       # map of player id -> owned cities
var _roads_mirror: Dictionary[int, AxialEdgeSet] = {}    # map of player id -> owned roads
var _bank: Dictionary[int, Wallet] = {}                  # map of player id -> owned resources
var _exchange_rate: Dictionary[int, Wallet] = {}         # map of player id -> exchange rate
var _owned_cards: Dictionary[int, ActionCardWallet] = {}    # map of player id -> all actions cards
var _playable_cards: Dictionary[int, ActionCardWallet] = {} # map of player id -> actions cards that can be played this turn
var _houses: Dictionary[String, int] = {}             # map of house axial -> player who owns it
var _cities: Dictionary[String, int] = {}             # map of city axial -> player who owns it
var _roads: Dictionary[String, int] = {}              # map of road axial -> player who owns it
var _ports: Dictionary[String, ResourceTypes] = {}    # map of port axial -> resource the port trades
var _road_building: int = 2                           # during road building phase, number of roads left to build
var _initial_houses: Dictionary[int, Array]           # initial house placements for each player
var _dice: Array[int] = [1, 1]                        # this is used for dev & debug - is not saved
var _discard_targets: Array[int] = []                 # during discard players discard to this amount
var _valid_corners: AxialSet = null                   # set once, corners that can be played on
var _valid_edges: AxialEdgeSet = null                 # set once, edges that can be played on
var rng := RandomNumberGenerator.new()

func get_pirate() -> Axial:                 return self._pirate.duplicate()
func get_current_player() -> int:           return self._current_player
func get_current_phase() -> GamePhase:      return self._game_phase
func get_port(cax: Axial) -> ResourceTypes: return self._ports.get(cax.key(), ResourceTypes.NONE)
func get_army(id: int) -> int:              return self._player_records[id].soldiers
func get_victory_points(id: int) -> int:    return self._player_records[id].victory_points
func get_dice() -> Array[int]:              return self._dice.duplicate()
func get_exchange_rate(id: int) -> Wallet:  return self._exchange_rate[id].duplicate()
func get_bank(id: int) -> Wallet:           return self._bank[id].duplicate()
func get_owned_action_cards(id: int) -> ActionCardWallet: return self._owned_cards[id]
func get_playable_action_cards(id: int) -> ActionCardWallet: return self._playable_cards[id]
func count_resources(id: int) -> int:       return self._bank[id].sum()
func get_longest_road() -> int:             return self._longest_road 
func get_largest_army() -> int:             return self._largest_army
func get_player_record(id: int) -> PlayerRecord: return self._player_records[id].duplicate()
func player_count() -> int:                 return self._player_records.size() # todo move all player counts to this
func free_road_count() -> int:              return self._road_building
func get_initial_houses(id: int) -> Array:  return self._initial_houses[id].duplicate()
func get_discard_target(id: int) -> int:    return self._discard_targets[id]
func valid_corners() -> AxialSet:           return self._valid_corners.duplicate()
func valid_edges() -> AxialEdgeSet:         return self._valid_edges.duplicate()

# return all edges that can accept a road (empty edges)
# not edges that only border water.
# Providing an id will only return the edges 
# adjacent to buildings or roads for that player.
func playable_edges(id: int = -1) -> AxialEdgeSet:
	var edge_set := self._valid_edges.duplicate()

	for pid in range(0, Game.player_count):
		edge_set = edge_set.difference(self._roads_mirror[pid])

	if id == -1: return edge_set

	var my_roads = self.get_roads(id)
	var my_buildings = self.get_all_buildings(id)
	var my_corners = my_roads.corner_map().union(my_buildings) 

	# remove oppenents buildings
	var their_buildings = self.get_all_buildings().difference(my_buildings)
	my_corners = my_corners.difference(their_buildings)

	var edges = my_corners.edge_map()
	return edges.intersect(edge_set).difference(self.get_roads())


# return all empty corners that can accept a house
# 1) does not have a house / city
# 2) is not adjacent to a house / city
# if an id is provided restrict the result to corners adjacent to an owned road edge
# if an id is not provided roads are not taken into account
func playable_corners(id: int = -1) -> AxialSet:
	var corners := self._valid_corners.duplicate()
	var houses = self.get_all_buildings()
	var neighbors := houses.map(Axial.neighbors_of)
	houses = houses.add(neighbors)
	corners = corners.difference(houses)

	if id == -1: return corners

	var roads := self.get_roads(id)
	var road_corners := roads.corner_map()
	return road_corners.intersect(corners)


func has_resources(id: int, wallet: Wallet) -> bool: 
	return self._bank[id].has(wallet)


## Get the player that has a house or city on this corner axial
## If there is no owner, or the axial is not a corner, returns -1
func get_owner(ax: Variant) -> int:
	
	if ax is AxialEdge:
		if self._roads.has(ax.key()):
			return self._roads[ax.key()]
	if ax is Axial:
		if self._cities.has(ax.key()):
			return self._cities[ax.key()]
		if self._houses.has(ax.key()):
			return self._houses[ax.key()]
	return -1


## Get all roads owned by id, or all roads if id is not provided
## If an array is passed in get roads for all listed ids
func get_roads(ids: Variant = -1) -> AxialEdgeSet:
	if ids is int: return self.get_roads([ids])

	var aset := AxialEdgeSet.new()

	for id in ids:
		if id == -1:
			for p in range(4):
				aset.add(self.get_roads(p))
		else:
			aset.add(self._roads_mirror[id])

	return aset	


## Get all houses owned by id, or all houses if id is not provided
func get_houses(id: int = -1) -> AxialSet:
	var aset := AxialSet.new()

	if id == -1:
		for p in range(4):
			aset.add(self.get_houses(p))
	else:
		aset.add(self._houses_mirror[id])

	return aset	


## Get all cities owned by id, or all cities if id is not provided
func get_cities(id: int = -1) -> AxialSet:
	var aset := AxialSet.new()

	if id == -1:
		for p in range(4):
			aset.add(self.get_cities(p))
	else:
		aset.add(self._cities_mirror[id])

	return aset


## Get all houses & cities owned by id, or all houses & cities if id is not provided
func get_all_buildings(id: int = -1) -> AxialSet:
	var result := AxialSet.new()
	result.add(self.get_houses(id))
	result.add(self.get_cities(id))
	return result


func all_hex_data() -> Array[HexData]:
	return self._hex_data.values()


func get_hex_data(hex: Axial) -> HexData:
	var data = self._hex_data.get(hex.key(), null)
	if data == null: return null

	if data and hex.equals(self._pirate):
		data.pirate = true
	else:
		data.pirate = false
	return data


func get_placement_phase(id: int) -> Model.PlacementPhase:
	if self.get_current_phase() != Model.GamePhase.SETUP: 
		return Model.PlacementPhase.NONE

	var count_houses = self.get_houses(id).size()
	var count_roads = self.get_roads(id).size()

	if count_houses == 0 and count_roads == 0:
		return Model.PlacementPhase.HOUSE1
	elif count_houses == 1 and count_roads == 0:
		return Model.PlacementPhase.ROAD1
	elif count_houses == 1 and count_roads == 1:
		return Model.PlacementPhase.HOUSE2
	elif count_houses == 2 and count_roads == 1:
		return Model.PlacementPhase.ROAD2
	else:
		return Model.PlacementPhase.NONE


func get_initial_road_targets(id: int) -> AxialEdgeSet:
	var house_axial = self.get_initial_houses(id)[-1]
	var edges = house_axial.edges()
	return edges	

func do_end_turn() -> void:
	# increment the current player
	self._current_player = (self._current_player + 1) % self.player_count()		

	# update playable action cards for new current player
	var owned = self._owned_cards[self._current_player]
	var playable = self._playable_cards[self._current_player]
	owned.copy_to(playable)

	# set turn
	self._game_phase = Model.GamePhase.PRE_ROLL

	# emit events
	EventBus.current_phase_updated.emit(self.get_current_phase())
	EventBus.current_player_updated.emit(self.get_current_player())	
	EventBus.action_cards_updated.emit(self._current_player, owned, playable)
	

func do_set_dice(d1: int, d2:int) -> void:
	self._dice[0] = d1
	self._dice[1] = d2
	EventBus.dice_set.emit(d1, d2)


func do_set_house(id: int, ax: Axial) -> void:	
	self._houses[ax.key()] = id
	self._houses_mirror[id].add(ax)
	self.do_add_victory_point(id)
	EventBus.house_added.emit(id, ax)
	self._calc_longest_road()


func do_set_initial_house(id: int, ax: Axial) -> void:
	self.do_set_house(id, ax)
	self._initial_houses[id].append(ax)


func do_set_city(id: int, ax: Axial) -> void:
	self._cities[ax.key()] = id
	self._cities_mirror[id].add(ax)
	self._houses_mirror[id].remove_item(ax)
	self.do_add_victory_point(id)
	EventBus.city_added.emit(id, ax)


func do_set_road(id: int, edge: AxialEdge) -> void:
	self._roads[edge.key()] = id
	self._roads_mirror[id].add(edge)
	EventBus.road_added.emit(id, edge)
	self._calc_longest_road()


func do_add_resources(id: int, resources: Wallet) -> void:
	self._bank[id].add_resources(resources)
	self._player_records[id].resources = self._bank[id].sum()
	EventBus.resources_updated.emit(id, self._bank[id].duplicate())


func do_remove_resources(id: int, resources:Wallet) -> void:
	self._bank[id].remove(resources)
	self._player_records[id].resources = self._bank[id].sum()
	EventBus.resources_updated.emit(id, self._bank[id].duplicate())

	for r in self._bank[id].keys():
		var count = self._bank[id].get_resource(r)
		if count < 0: 
			EventBus.error.emit("On player %s resource %s = %s" % [id, Model.ResourceTypes.find_key(r), count])


func do_discard(id: int, resources:Wallet) -> void:
	self._discard_targets[id] = self._discard_targets[id] - resources.sum()
	self.do_remove_resources(id, resources)


func do_add_action_card(id: int, card: ActionCardTypes) -> void:
	self._owned_cards[id].add_card(card)
	var owned := self._owned_cards[id].duplicate()
	var playable := self._playable_cards[id].duplicate()

	self._player_records[id].action_cards = owned.size()

	EventBus.action_cards_updated.emit(id, owned, playable)


func do_remove_action_card(id: int, card) -> void:
	self._owned_cards[id].remove_card(card)
	self._playable_cards[id].set_all(0)
	var owned := self._owned_cards[id].duplicate()
	var playable := self._playable_cards[id].duplicate()
	self._player_records[id].action_cards = owned.size()

	EventBus.action_cards_updated.emit(id, owned, playable)	


func update_discard_targets() -> void:
	for pid in self.player_count():
		self._discard_targets[pid] = 0
		if self._bank[pid].sum() <= 7: continue
		self._discard_targets[pid] = self._bank[pid].sum() / 2

	print("Model Update Discard Targets %s" % [self._discard_targets])

func do_update_phase(phase: GamePhase) -> void:
	print("Model Do Update Phase %s" % [phase])
	self._game_phase = phase

	if phase == Model.GamePhase.ROAD_BUILDING:
		self._road_building = 2	

	if phase == Model.GamePhase.DISCARD:
		self.update_discard_targets()

	for pid in self.player_count():
		self._playable_cards[pid].copy_from(self._owned_cards[pid])

	EventBus.current_phase_updated.emit(phase)


func do_update_player(id: int) -> void:
	self._current_player = id
	EventBus.current_player_updated.emit(id)


func do_set_exchange_rate(id: int, resource, value: int) -> void:
	self._exchange_rate[id].set_resource(resource, value)
	EventBus.exchange_rate_set.emit(id, self._exchange_rate[id].duplicate())


func do_set_pirate(ax: Axial) -> void:
	self._hex_data[self._pirate.key()].pirate = false
	self._pirate = ax.duplicate()
	self._hex_data[self._pirate.key()].pirate = true
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


func reset_road_building() -> void:
	self._road_building = 2


func decrement_road_building() -> void:
	self._road_building = self._road_building - 1


func _init() -> void:
	for id in Game.player_count:
		self._bank[id] = Wallet.new()
		self._exchange_rate[id] = Wallet.new(4)
		self._owned_cards[id] = ActionCardWallet.new()
		self._playable_cards[id] = ActionCardWallet.new()
		self._houses_mirror[id] = AxialSet.new()
		self._cities_mirror[id] = AxialSet.new()
		self._roads_mirror[id] = AxialEdgeSet.new()	
		self._player_records[id] = PlayerRecord.new(id)
		self._initial_houses[id] = []
		
	self._discard_targets.resize(Game.player_count)
	self._discard_targets.fill(0)


func build(names: Array[String]) -> void:
	for id in range(Game.player_count):
		self._player_records[id].name = names[id]

	var hexes := self._place_tiles()
	self._place_water(hexes)
	self._place_ports()
	self.build_derived_data()


func build_derived_data():	
	self._valid_corners = AxialSet.new()
	self._valid_edges = AxialEdgeSet.new()

	for hex_data: HexData in self.all_hex_data():
		if hex_data.terrain == Model.Terrain.WATER: continue
		self._valid_corners.add(hex_data.axial.corners())	

	for hex_data in self._hex_data.values():
		if hex_data.terrain == Terrain.WATER: continue
		self._valid_edges.add(hex_data.axial.edges())


# populates (non-wate) hexes, corners, edges
# populate hexdata with hex, terrain, resource
# set pirate
func _place_tiles() -> AxialSet:
	var terrain_bag := self._fill_terrain_bag()
	var number_bag: Array[int] = [2, 3, 3, 4, 4, 5, 5, 6, 6, 8, 8, 9, 9, 10, 10, 11, 11, 12]
	number_bag.shuffle()

	var neighbors := Axial.zero().neighbors()
	var distant_neighbors := neighbors.map(Axial.neighbors_of)

	var hexes: AxialSet = AxialSet.new()

	hexes.add(Axial.zero())
	hexes.add(neighbors)
	hexes.add(distant_neighbors)

	for hex in hexes:
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

	return hexes

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
	self._hex_data[hex.key()].ports.add(cax.duplicate())
	self._hex_data[hex.key()].port_type = value


# populates water hexes and hexdata
func _place_water(hexes: AxialSet) -> void:
	var water := hexes.map(Axial.neighbors_of)
	water = water.difference(hexes)

	for hex in water:
		self._hex_data[hex.key()] = HexData.new()
		self._hex_data[hex.key()].axial = hex
		self._hex_data[hex.key()].terrain = Terrain.WATER

	hexes.add(water)	


func _fill_terrain_bag() -> Array[Terrain]:
	var terrain_bag: Array[Terrain] = []

	for terrain in TERRAIN_COUNTS:
		for i in TERRAIN_COUNTS[terrain]:
			terrain_bag.append(terrain)
	terrain_bag.shuffle()

	return terrain_bag


func resources_of(corner: Axial) -> Wallet:
	var wallet := Wallet.new()

	for hex: Axial in corner.hexes():
		var hexdata = self.get_hex_data(hex)
		if hexdata.resource == Model.ResourceTypes.NONE: continue
		wallet.add_resource(hexdata.resource)

	return wallet


func _calc_longest_road() -> void:
	# calculate all road lengths
	for pid in range(Game.player_count):
		var length := LongestRoadCalculator.calculate_longest_road(pid, self)
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
