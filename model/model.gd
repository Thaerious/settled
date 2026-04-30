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
	NONE
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

var _largest_army_player: int = -1
var _longest_road_player: int = -1
var _current_player: int = 0
var _game_phase: GamePhase = GamePhase.NOT_STARTED
var _robber: Axial
var _hexes: AxialSet = AxialSet.new()
var _corners: AxialSet = AxialSet.new()
var _edges: AxialEdgeSet = AxialEdgeSet.new()
var _terrain: Dictionary[String, Terrain] = {}       # axial (hex) -> terrain
var _numbers: Dictionary[String, int] = {}           # axial (hex) -> number
var _houses: Dictionary[String, int] = {}            # axial (corner) -> player id
var _cities: Dictionary[String, int] = {}            # axial (corner) -> player id
var _roads: Dictionary[String, int] = {}             # axial edge -> player id

var _houses_mirror: Dictionary[int, Array] = {}      # player id -> [axial (corner)]
var _cities_mirror: Dictionary[int, Array] = {}      # player id -> [axial (corner)]
var _roads_mirror: Dictionary[int, Array] = {}       # player id -> [axial edge]

var _bank: Dictionary[int, Dictionary] = {}          # player id -> resource -> quantity
var _action_cards: Dictionary[int, Dictionary] = {}  # player id -> card -> quantity
var _victory_points: Dictionary[int, int] = {}       # player id -> points
var _army : Dictionary[int, int] = {}                # player id -> soldier cards played
var _ports: Dictionary[String, String] = {}          # axial (corner) -> resource ("any" for 3:1)
var _port_hosts: Dictionary[String, String] = {}     # tiles that have ports

func all_hexes() -> AxialSet:          return self._hexes.duplicate(true) 
func all_corners() -> AxialSet:	       return self._corners.duplicate(true) # valid playable corners
func all_edges() -> AxialEdgeSet:      return self._edges.duplicate(true) # valid playable corners
func get_robber() -> Axial:            return self._robber.duplicate()
func get_current_player() -> int:      return self._current_player
func get_current_phase() -> GamePhase: return self._game_phase

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


func get_hex_data(ax: Axial) -> HexData:
	assert(ax.is_hex(), "Axial is not a hex.")

	var data = HexData.new()
	data.axial = ax.duplicate()
	data.terrain = self._terrain[ax.key()]
	data.resource = self.TERRAIN_TO_RESOURCE[data.terrain]
	data.number = self._numbers.get(ax.key(), -1)
	data.robber = self._robber == ax
	data.port_type = self._port_hosts.get(ax.key(), "none")

	if data.port_type != "none":
		for corner in ax.corners():
			if not self._ports.has(corner.key()): continue
			data.ports.add_item(corner.duplicate())
	return data


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

	for i in range(4):
		self._bank[i] = {} as Dictionary[ResourceTypes, int]
		self._action_cards[i] = {}
		self._army[i] = 0
		self._victory_points[i] = 0
		self._houses_mirror[i] = [] as Array[Axial]
		self._cities_mirror[i] = [] as Array[Axial]
		self._roads_mirror[i] = [] as Array[AxialEdge]

		for r in ResourceTypes.values():
			self._bank[i][r] = 0

		for c in ActionCards.values():
			self._action_cards[i][c] = 0			


func _build_axials() -> void:
	var neighbors := Axial.zero().neighbors() # first ring
	var distant_neighbors := neighbors.flat_map(Axial.neighbors_of) # second ring

	self._hexes.add_item(Axial.zero())
	self._hexes.add_all(neighbors)
	self._hexes.add_all(distant_neighbors)
	self._corners = self._hexes.flat_map(Axial.corners_of)
	self._edges = self._hexes.edge_map(Axial.edges_of)


func _place_land() -> void:
	var terrain_bag := self._fill_terrain_bag()

	for hex in self._hexes:
		var terrain: Terrain = terrain_bag.pop_front()
		self._terrain[hex.key()] = terrain


func _place_ports() -> void:	
	self._place_port(Axial.new(0, -3, 3), 2, "any")
	self._place_port(Axial.new(0, -3, 3), 3, "any")

	self._place_port(Axial.new(2, -3, 1), 3, "brick")
	self._place_port(Axial.new(2, -3, 1), 4, "brick")

	self._place_port(Axial.new(3, -2, -1), 3, "any")
	self._place_port(Axial.new(3, -2, -1), 4, "any")

	self._place_port(Axial.new(3, 0, -3), 4, "wood")
	self._place_port(Axial.new(3, 0, -3), 5, "wood")

	self._place_port(Axial.new(1, 2, -3), 5, "wool")
	self._place_port(Axial.new(1, 2, -3), 0, "wool")

	self._place_port(Axial.new(-1, 3, -2), 5, "rock")
	self._place_port(Axial.new(-1, 3, -2), 0, "rock")	

	self._place_port(Axial.new(-3, 3, 0), 0, "any")
	self._place_port(Axial.new(-3, 3, 0), 1, "any")	

	self._place_port(Axial.new(-3, 1, 2), 1, "wheat")
	self._place_port(Axial.new(-3, 1, 2), 2, "wheat")	

	self._place_port(Axial.new(-2, -1, 3), 1, "any")
	self._place_port(Axial.new(-2, -1, 3), 2, "any")	


func _place_port(ax: Axial, corner: int, value: String) -> void:
	var cax = ax.corners().to_array()[corner]
	self._ports[cax.key()] = value
	self._port_hosts[ax.key()] = value


func _place_water()-> void:
	var water := self._hexes.flat_map(Axial.neighbors_of)
	water = water.difference(self._hexes) # keep the outside hexes only

	for hex in water: self._terrain[hex.key()] = Terrain.WATER
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
		if (self._terrain[hex.key()] == Terrain.DESERT):
			self._robber = hex
		else:
			self._numbers[hex.key()] = number_bag.pop_front()
