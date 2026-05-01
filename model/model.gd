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
	Terrain.MOUNTAIN: ResourceTypes.ROCK,
	Terrain.FIELD: ResourceTypes.WHEAT,
	Terrain.PASTURE: ResourceTypes.WOOL,
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
	ROCK,
	WHEAT,
	WOOL,
	NONE,
	ANY
}

enum ActionCards {
	SOLDIER,
	BUILD_ROAD,
	PLENTY,
	MONOPOLY,
	VICTORY_POINTS
}

const CARD_DISTRIBUTION : Dictionary[Model.ActionCards, int] = {
	ActionCards.SOLDIER: 56,
	ActionCards.BUILD_ROAD: 20,
	ActionCards.PLENTY: 8,
	ActionCards.MONOPOLY: 8,
	ActionCards.VICTORY_POINTS: 8,
}

enum GamePhase {
	NOT_STARTED,
	SETUP_FORWARD_HOUSE,
	SETUP_FORWARD_ROAD,
	SETUP_REVERSE_HOUSE,
	SETUP_REVERSE_ROAD,
	MAIN,
	GAME_OVER,	
}

# var _largest_army_player: int = -1
# var _longest_road_player: int = -1
var _current_player: int = 0
var _game_phase: GamePhase = GamePhase.NOT_STARTED
var _robber: Axial
var _hexes: AxialSet = AxialSet.new()
var _corners: AxialSet = AxialSet.new()
var _edges: AxialEdgeSet = AxialEdgeSet.new()

var _hex_data: Dictionary[String, HexData] = {}      # axial (hex) -> data

var _houses: Dictionary[String, int] = {}            # axial (corner) -> player id
var _cities: Dictionary[String, int] = {}            # axial (corner) -> player id
var _roads: Dictionary[String, int] = {}             # axial edge -> player id

var _houses_mirror: Dictionary[int, Array] = {}      # player id -> [axial (corner)]
var _cities_mirror: Dictionary[int, Array] = {}      # player id -> [axial (corner)]
var _roads_mirror: Dictionary[int, Array] = {}       # player id -> [axial edge]

var _bank: Dictionary[int, Dictionary] = {}          # player id -> resource -> quantity
var _exchange_rate: Dictionary[int, Dictionary] = {} # player id -> resource -> quantity
var _action_cards: Dictionary[int, Dictionary] = {}  # player id -> card -> quantity
var _victory_points: Dictionary[int, int] = {}       # player id -> points
var _army : Dictionary[int, int] = {}                # player id -> soldier cards played
var _ports: Dictionary[String, ResourceTypes] = {}   # axial (corner) -> resource ("any" for 3:1)

func all_hexes() -> AxialSet:               return self._hexes.duplicate(true) 
func all_corners() -> AxialSet:	            return self._corners.duplicate(true) # valid playable corners
func all_edges() -> AxialEdgeSet:           return self._edges.duplicate(true) # valid playable corners
func get_robber() -> Axial:                 return self._robber.duplicate()
func get_current_player() -> int:           return self._current_player
func get_current_phase() -> GamePhase:      return self._game_phase
func get_port(cax: Axial) -> ResourceTypes: return self._ports.get(cax.key(), ResourceTypes.NONE)

func get_exchange_rate(id: int, r: ResourceTypes) -> int: return self._exchange_rate[id][r]

func has_resources(id: int, brick: int, wood: int, wool: int, wheat: int, rock: int) -> bool:
	var bank = self._bank[id]
	if bank[ResourceTypes.BRICK] < brick: return false
	if bank[ResourceTypes.WOOD] < wood: return false
	if bank[ResourceTypes.WOOL] < wool: return false
	if bank[ResourceTypes.WHEAT] < wheat: return false
	if bank[ResourceTypes.ROCK] < rock: return false
	return true
	

func get_houses(id: int = -1) -> AxialSet:
	var aset := AxialSet.new()

	if id == -1:
		for p in range(Game.player_count):
			aset.add_all(self._houses_mirror[p])
	else:
		aset.add_all(self._houses_mirror[id])

	return aset


func get_cities(id: int = -1) -> AxialSet:
	var aset := AxialSet.new()

	if id == -1:
		for p in range(Game.player_count):
			aset.add_all(self._cities_mirror[p])
	else:
		aset.add_all(self._cities_mirror[id])

	return aset


func all_buildings(id: int = -1) -> AxialSet:
	var result := AxialSet.new()
	
	if id == -1:
		for p in range(4):
			result.add_all(self._houses_mirror[p])
	else:
		result.add_all(self._houses_mirror[id])
		result.add_all(self._cities_mirror[id])

	return result


func get_hex_data(hex: Axial) -> HexData:
	assert(hex.is_hex(), "Axial is not a hex.")
	return self._hex_data[hex.key()]


func get_bank(id: int) -> Dictionary[ResourceTypes, int]:
	return self._bank[id]


func _init() -> void:
	Service.new()

	self._build_axials()
	self._place_land()
	self._place_numbers()
	self._place_water()
	self._place_ports()
	EventBus.set_house.connect(func (id, ax): 
		self._houses[ax.key()] = id
		self._houses_mirror[id].append(ax)
	)

	EventBus.set_city.connect(func (id, ax):
		self._cities[ax.key()] = id
		self._cities_mirror[id].append(ax)
		self._houses_mirror[id].erase(ax)
	)

	EventBus.set_road.connect(func (id, ax):
		self._roads[ax.key()] = id
		self._roads_mirror[id].append(ax)
	)

	EventBus.add_resources.connect(func(id, resources):
		for resource: ResourceTypes in resources:
			self._bank[id][resource] += 1
	)

	EventBus.remove_resources.connect(func(id, resources):
		for resource: ResourceTypes in resources:
			self._bank[id][resource] -= 1
	)

	EventBus.add_action_card.connect(func(id, card):
		self._action_cards[id][card] += 1
	)

	EventBus.update_player_phase.connect(func(id, phase):
		self._current_player = id
		self._game_phase = phase
	)

	EventBus.set_exchange_rate.connect(func(id, resource, value):
		self._exchange_rate[id][resource] = value
	)

	for i in range(4):
		self._bank[i] = {} as Dictionary[ResourceTypes, int]
		self._exchange_rate[i] = {} as Dictionary[ResourceTypes, int]
		self._action_cards[i] = {}
		self._army[i] = 0
		self._victory_points[i] = 0
		self._houses_mirror[i] = [] as Array[Axial]
		self._cities_mirror[i] = [] as Array[Axial]
		self._roads_mirror[i] = [] as Array[AxialEdge]

		for r in ResourceTypes.values():
			self._bank[i][r] = 0
			self._exchange_rate[i][r] = 4

		for c in ActionCards.values():
			self._action_cards[i][c] = 0			


# populate the _hexes, _corners, and _edges fields
# these are the playable values (ie water has no edges)
func _build_axials() -> void:
	var neighbors := Axial.zero().neighbors() # first ring
	var distant_neighbors := neighbors.flat_map(Axial.neighbors_of) # second ring

	self._hexes.add_item(Axial.zero())
	self._hexes.add_all(neighbors)
	self._hexes.add_all(distant_neighbors)
	self._corners = self._hexes.flat_map(Axial.corners_of)
	self._edges = self._hexes.edge_map(Axial.edges_of)

	for hex in self._hexes:
		self._hex_data[hex.key()] = HexData.new()
		self._hex_data[hex.key()].axial = hex

	
func _place_land() -> void:
	var terrain_bag := self._fill_terrain_bag()

	for hex in self._hexes:
		var terrain: Terrain = terrain_bag.pop_front()
		self._hex_data[hex.key()].terrain = terrain


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


func _place_port(hex: Axial, corner: int, value: ResourceTypes) -> void:
	var cax = hex.corners().to_array()[corner]
	self._ports[cax.key()] = value
	self._hex_data[hex.key()].ports.add_item(cax.duplicate())
	self._hex_data[hex.key()].port_type = value


func _place_water()-> void:
	var water := self._hexes.flat_map(Axial.neighbors_of)
	water = water.difference(self._hexes) # keep the outside hexes only

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


func _place_numbers() -> void:
	var number_bag:Array[int] = [2, 3, 3, 4, 4, 5, 5, 6, 6, 8, 8, 9, 9, 10, 10, 11, 11, 12]

	number_bag.shuffle()
	for hex in self._hexes:
		if (self.get_hex_data(hex).terrain == Terrain.DESERT):
			self._robber = hex
			self._hex_data[hex.key()].robber = true
		else:
			self._hex_data[hex.key()].number = number_bag.pop_front()
