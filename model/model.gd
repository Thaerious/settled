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
	STEAL_RESOURCES,
	MAIN,
	GAME_OVER,	
}

var _current_player: int = 0
var player_names: Array = [] ## todo this needs a getter
var _game_phase: GamePhase = GamePhase.NOT_STARTED
var _pirate: Axial
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
func get_pirate() -> Axial:                 return self._pirate.duplicate()
func get_current_player() -> int:           return self._current_player
func get_current_phase() -> GamePhase:      return self._game_phase
func get_port(cax: Axial) -> ResourceTypes: return self._ports.get(cax.key(), ResourceTypes.NONE)
func get_army(id: int) -> int:              return self._army[id]
func get_victory_points(id: int) -> int:    return self._victory_points[id]

func get_exchange_rate(id: int, r: ResourceTypes) -> int: return self._exchange_rate[id][r]

func count_resources(id: int) -> int:
	var bank = self.get_bank(id)
	print(bank)

	var sum:int = 0
	sum = sum + bank[ResourceTypes.BRICK]
	sum = sum + bank[ResourceTypes.WOOD]
	sum = sum + bank[ResourceTypes.WOOL]
	sum = sum + bank[ResourceTypes.WHEAT]
	sum = sum + bank[ResourceTypes.ROCK]

	return sum


func has_resources(id: int, brick: int, wood: int, wool: int, wheat: int, rock: int) -> bool:
	var bank = self._bank[id]
	if bank[ResourceTypes.BRICK] < brick: return false
	if bank[ResourceTypes.WOOD] < wood: return false
	if bank[ResourceTypes.WOOL] < wool: return false
	if bank[ResourceTypes.WHEAT] < wheat: return false
	if bank[ResourceTypes.ROCK] < rock: return false
	return true
	

func get_owner(ax: Axial) -> int:
	if self._cities.has(ax.key()):
		return self._cities[ax.key()]

	if self._houses.has(ax.key()):
		return self._houses[ax.key()]

	return -1		


func get_roads(id: int) -> AxialEdgeSet:
	var aset := AxialEdgeSet.new()
	aset.add_all(self._roads_mirror[id])
	return aset


func get_houses(id: int) -> AxialSet:
	var aset := AxialSet.new()
	aset.add_all(self._houses_mirror[id])
	return aset


func get_cities(id: int) -> AxialSet:
	var aset := AxialSet.new()
	aset.add_all(self._cities_mirror[id])
	return aset


func get_all_buildings(id: int = -1) -> AxialSet:
	var result := AxialSet.new()
	
	if id == -1:
		for p in range(4):
			result.add_all(self._houses_mirror[p])
	else:
		result.add_all(self._houses_mirror[id])
		result.add_all(self._cities_mirror[id])

	return result


func get_hex_data(hex: Axial) -> HexData:
	return self._hex_data.get(hex.key(), null)


func get_bank(id: int) -> Dictionary[ResourceTypes, int]:
	return self._bank[id]


func get_action_cards(id: int) -> Dictionary[ActionCardTypes, int]:
	return self._action_cards[id]


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

	EventBus.request_set_pirate.connect(func(_id, ax):
		print("Model Set Pirate %s" % ax)
		self._pirate = ax.duplicate()
	)

	self.player_names.resize(4)

	for i in range(4):
		self._bank[i] = {} as Dictionary[ResourceTypes, int]
		self._exchange_rate[i] = {} as Dictionary[ResourceTypes, int]
		self._action_cards[i] = {} as Dictionary[ActionCardTypes, int]
		self._army[i] = 0
		self._victory_points[i] = 0
		self._houses_mirror[i] = [] as Array[Axial]
		self._cities_mirror[i] = [] as Array[Axial]
		self._roads_mirror[i] = [] as Array[AxialEdge]

		for r in ResourceTypes.values():
			self._bank[i][r] = 0
			self._exchange_rate[i][r] = 4

		for c in ActionCardTypes.values():
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
		if terrain == Terrain.DESERT:
			self._hex_data[hex.key()].pirate = true
			self._pirate = hex


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
	for hex_data in self._hex_data.values():
		if hex_data.terrain == Terrain.DESERT: continue
		if hex_data.terrain == Terrain.WATER: continue
		hex_data.number = number_bag.pop_front()


## Save / Load Methods and Helpers
func save(path: String) -> void:
	var data := {
		"player_names": _serialize_player_names(),
		"current_player": _current_player,
		"game_phase": _game_phase,
		"pirate": _pirate.key(),
		"hex_data": _serialize_hex_data(),
		"houses": _houses,
		"cities": _cities,
		"roads": _serialize_roads(),
		"houses_mirror": _serialize_axial_mirror(_houses_mirror),
		"cities_mirror": _serialize_axial_mirror(_cities_mirror),
		"roads_mirror": _serialize_edge_mirror(_roads_mirror),
		"bank": _serialize_int_keyed(_bank),
		"exchange_rate": _serialize_int_keyed(_exchange_rate),
		"action_cards": _serialize_int_keyed(_action_cards),
		"victory_points": _victory_points,
		"army": _army,
		"ports": _serialize_ports(),
	}
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string(JSON.stringify(data))


func load(path: String) -> void:
	var f := FileAccess.open(path, FileAccess.READ)
	var data: Dictionary = JSON.parse_string(f.get_as_text())

	_current_player = int(data["current_player"])
	_game_phase = int(data["game_phase"]) as GamePhase
	_pirate = Axial.from_key(data["pirate"])

	_deserialize_hex_data(data["hex_data"])

	_houses.clear()
	for k in data["houses"]: _houses[k] = int(data["houses"][k])

	_cities.clear()
	for k in data["cities"]: _cities[k] = int(data["cities"][k])

	_deserialize_roads(data["roads"])
	_deserialize_axial_mirror(_houses_mirror, data["houses_mirror"])
	_deserialize_axial_mirror(_cities_mirror, data["cities_mirror"])
	_deserialize_edge_mirror(_roads_mirror, data["roads_mirror"])
	_deserialize_int_keyed(_bank, data["bank"])
	_deserialize_int_keyed(_exchange_rate, data["exchange_rate"])
	_deserialize_int_keyed(_action_cards, data["action_cards"])
	_deserialize_player_names(data["player_names"])

	_victory_points.clear()
	for k in data["victory_points"]: _victory_points[int(k)] = int(data["victory_points"][k])

	_army.clear()
	for k in data["army"]: _army[int(k)] = int(data["army"][k])

	_deserialize_ports(data["ports"])


# --- Serialize Helpers ---

func _serialize_hex_data() -> Dictionary:
	var out := {}
	for k in _hex_data:
		var hd: HexData = _hex_data[k]
		out[k] = {
			"axial": hd.axial.key(),
			"terrain": hd.terrain,
			"number": hd.number,
			"pirate": hd.pirate,
			"port_type": hd.port_type,
			"ports": hd.ports.to_array().map(Axial.to_key),
		}
	return out


func _serialize_player_names() -> Dictionary:
	var out := {}
	for i in self.player_names.size():
		out[i] = self.player_names[i]
	return out


func _deserialize_player_names(data: Dictionary) -> void:
	self.player_names = []
	self.player_names.resize(data.size())
	for k in data:
		self.player_names[int(k)] = data[k]


func _deserialize_hex_data(data: Dictionary) -> void:
	_hex_data.clear()
	for k in data:
		var d: Dictionary = data[k]
		var hd := HexData.new()
		hd.axial = Axial.from_key(d["axial"])
		hd.terrain = int(d["terrain"]) as Model.Terrain
		hd.number = int(d["number"])
		hd.pirate = bool(d["pirate"])
		hd.port_type = int(d["port_type"]) as Model.ResourceTypes
		for pk in d["ports"]:
			hd.ports.add_item(Axial.from_key(pk))
		_hex_data[k] = hd


func _serialize_roads() -> Dictionary:
	var out := {}
	for k in _roads:
		out[k] = _roads[k]
	return out


func _deserialize_roads(data: Dictionary) -> void:
	_roads.clear()
	for k in data: _roads[k] = int(data[k])


func _serialize_axial_mirror(mirror: Dictionary) -> Dictionary:
	var out := {}
	for id in mirror:
		out[str(id)] = (mirror[id] as Array).map(Axial.to_key)
	return out


func _deserialize_axial_mirror(mirror: Dictionary, data: Dictionary) -> void:
	for id in mirror:
		mirror[id].clear()
	for k in data:
		var id := int(k)
		for ak in data[k]:
			mirror[id].append(Axial.from_key(ak))


func _serialize_edge_mirror(mirror: Dictionary) -> Dictionary:
	var out := {}
	for id in mirror:
		out[str(id)] = (mirror[id] as Array).map(func(e: AxialEdge): return {
			"key": e.key(),
			"rot": e.rotation
		})
	return out


func _deserialize_edge_mirror(mirror: Dictionary, data: Dictionary) -> void:
	for id in mirror:
		mirror[id].clear()
	for k in data:
		var id := int(k)
		for ed in data[k]:
			var edge := AxialEdge.from_key(ed["key"])
			edge.rotation = float(ed["rot"])
			mirror[id].append(edge)


func _serialize_int_keyed(d: Dictionary) -> Dictionary:
	var out := {}
	for id in d:
		var inner := {}
		for k in d[id]: inner[str(k)] = d[id][k]
		out[str(id)] = inner
	return out


func _deserialize_int_keyed(target: Dictionary, data: Dictionary) -> void:
	for id in target:
		target[id].clear()
	for k in data:
		var id := int(k)
		for ik in data[k]:
			target[id][int(ik)] = int(data[k][ik])


func _serialize_ports() -> Dictionary:
	var out := {}
	for k in _ports: out[k] = _ports[k]
	return out


func _deserialize_ports(data: Dictionary) -> void:
	_ports.clear()
	for k in data: _ports[k] = int(data[k]) as Model.ResourceTypes

	
