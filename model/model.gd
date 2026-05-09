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
	DISCARD,
	STEAL_RESOURCES,
	MAIN,
	YEAR_OF_PLENTY,
	MONOPOLY,
	ROAD_BUILDING,
	SOLDIER,
	GAME_OVER,
}

var _current_player: int = 0
var player_names: Array = []
var _game_phase: GamePhase = GamePhase.NOT_STARTED
var _pirate: Axial
var _hexes: AxialSet = AxialSet.new()
var _corners: AxialSet = AxialSet.new()
var _edges: AxialEdgeSet = AxialEdgeSet.new()

var _hex_data: Dictionary[String, HexData] = {}

var _houses: Dictionary[String, int] = {}
var _cities: Dictionary[String, int] = {}
var _roads: Dictionary[String, int] = {}

var _houses_mirror: Dictionary[int, Array] = {}
var _cities_mirror: Dictionary[int, Array] = {}
var _roads_mirror: Dictionary[int, Array] = {}

var _bank: Dictionary[int, Wallet] = {}
var _exchange_rate: Dictionary[int, Wallet] = {}
var _action_cards: Dictionary[int, ActionCardWallet] = {}
var _victory_points: Dictionary[int, int] = {}
var _army: Dictionary[int, int] = {}
var _ports: Dictionary[String, ResourceTypes] = {}

var _dice: Array[int] = [1, 1]


func all_hexes() -> AxialSet:               return self._hexes.duplicate(true)
func all_corners() -> AxialSet:             return self._corners.duplicate(true)
func all_edges() -> AxialEdgeSet:           return self._edges.duplicate(true)
func get_pirate() -> Axial:                 return self._pirate.duplicate()
func get_current_player() -> int:           return self._current_player
func get_current_phase() -> GamePhase:      return self._game_phase
func get_port(cax: Axial) -> ResourceTypes: return self._ports.get(cax.key(), ResourceTypes.NONE)
func get_army(id: int) -> int:              return self._army[id]
func get_victory_points(id: int) -> int:    return self._victory_points[id]
func get_dice() -> Array[int]:              return self._dice.duplicate()

func get_exchange_rate(id: int, r: ResourceTypes) -> int: return self._exchange_rate[id].get_resource(r)

func get_bank(id: int) -> Wallet:
	return self._bank[id].duplicate()

func get_action_cards(id: int) -> ActionCardWallet:
	return self._action_cards[id]

func count_resources(id: int) -> int:
	return self._bank[id].count_resources()

func has_resources(id: int, brick: int, wood: int, wool: int, wheat: int, rock: int) -> bool:
	return self._bank[id].has_resources(brick, wood, rock, wheat, wool)


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
	var data = self._hex_data.get(hex.key(), null)
	if data and hex.equals(self._pirate):
		data.pirate = true
	else:
		data.pirate = false
	return data


func do_set_dice(d1: int, d2:int) -> void:
	self._dice[0] = d1
	self._dice[1] = d2
	EventBus.dice_set.emit(d1, d2)


func do_set_house(id: int, ax: Axial) -> void:	
	self._houses[ax.key()] = id
	self._houses_mirror[id].append(ax)
	self.do_add_victory_point(id)
	EventBus.house_added.emit(id, ax)


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


func do_add_resources(id: int, resources) -> void:
	self._bank[id].add_resources(resources)
	EventBus.add_resources.emit(id, resources)


func do_remove_resources(id: int, resources) -> void:
	self._bank[id].remove_resources(resources)
	EventBus.remove_resources.emit(id, resources)


func do_add_action_card(id: int, card) -> void:
	self._action_cards[id].add_card(card)
	EventBus.update_action_card.emit(id, self._action_cards[id].duplicate())


func do_remove_action_card(id: int, card) -> void:
	self._action_cards[id].remove_card(card)
	EventBus.update_action_card.emit(id, self._action_cards[id].duplicate())


func do_update_phase(phase: GamePhase) -> void:
	self._game_phase = phase
	EventBus.phase_updated.emit(phase)


func do_update_player(id: int) -> void:
	self._current_player = id
	EventBus.player_updated.emit(id)


func do_set_exchange_rate(id: int, resource, value: int) -> void:
	self._exchange_rate[id].set_resource(resource, value)
	EventBus.exchange_rate_set.emit(id, resource, value)


func do_set_pirate(ax: Axial) -> void:
	self._pirate = ax.duplicate()
	EventBus.pirate_set.emit(ax.duplicate())


func do_add_victory_point(id: int, amt: int = 1) -> void:
	self._victory_points[id] += amt
	EventBus.victory_points_updated.emit(id, self._victory_points[id])


func do_remove_victory_point(id: int, amt: int = 1) -> void:
	self._victory_points[id] -= amt
	EventBus.victory_points_updated.emit(id, self._victory_points[id])


func do_add_soldier(id: int) -> void:
	self._army[id] += 1
	EventBus.soldier_added.emit(id)


func _init() -> void:
	self._place_tiles()
	self._place_water()
	self._place_ports()

	self.player_names.resize(4)

	for i in range(4):
		self._bank[i] = Wallet.new()
		self._exchange_rate[i] = Wallet.new()
		self._exchange_rate[i].set_all(4)
		self._action_cards[i] = ActionCardWallet.new()
		self._army[i] = 0
		self._victory_points[i] = 0
		self._houses_mirror[i] = [] as Array[Axial]
		self._cities_mirror[i] = [] as Array[Axial]
		self._roads_mirror[i] = [] as Array[AxialEdge]


# populates (non-wate) hexes, corners, edges
# populate hexdata with hex, terrain, resource
# set pirate
func _place_tiles() -> void:
	var terrain_bag := self._fill_terrain_bag()
	var number_bag: Array[int] = [2, 3, 3, 4, 4, 5, 5, 6, 6, 8, 8, 9, 9, 10, 10, 11, 11, 12]
	number_bag.shuffle()

	var neighbors := Axial.zero().neighbors()
	var distant_neighbors := neighbors.flat_map(Axial.neighbors_of)

	self._hexes.add_item(Axial.zero())
	self._hexes.add_all(neighbors)
	self._hexes.add_all(distant_neighbors)
	self._corners = self._hexes.flat_map(Axial.corners_of)
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
	var water := self._hexes.flat_map(Axial.neighbors_of)
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
		"bank": _serialize_wallet_collection(_bank),
		"exchange_rate": _serialize_wallet_collection(_exchange_rate),
		"action_cards": _serialize_action_card_collection(_action_cards),
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
	_deserialize_wallet_collection(data["bank"], _bank)
	_deserialize_wallet_collection(data["exchange_rate"], _exchange_rate)
	_deserialize_action_card_collection(data["action_cards"], _action_cards)
	_deserialize_player_names(data["player_names"])

	_victory_points.clear()
	for k in data["victory_points"]: _victory_points[int(k)] = int(data["victory_points"][k])

	_army.clear()
	for k in data["army"]: _army[int(k)] = int(data["army"][k])

	_deserialize_ports(data["ports"])

	print("loaded pirate: %s" % self._pirate)


func _serialize_hex_data() -> Dictionary:
	var out := {}
	for k in _hex_data: # k is axial.key()
		out[k] = _hex_data[k].serialize()
	return out


func _deserialize_hex_data(data: Dictionary) -> void:
	_hex_data.clear()
	for k in data: # k is axial.key()
		var hd = HexData.deserialize(data[k])		
		_hex_data[k] = hd


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


func _serialize_wallet_collection(input: Dictionary) -> Dictionary:
	var out := {}
	for id in input:
		var w: Wallet = input[id]
		var inner := {}
		for r in w.keys():
			inner[str(r)] = w.get_resource(r)
		out[str(id)] = inner
	return out


func _deserialize_wallet_collection(data: Dictionary, target: Dictionary) -> void:
	for k in data:
		var w: Wallet = target[int(k)]
		for r in data[k]:
			w.set_resource(int(r) as Model.ResourceTypes, int(data[k][r]))


func _serialize_action_card_collection(input: Dictionary) -> Dictionary:
	var out := {}
	for id in input:
		var w: ActionCardWallet = input[id]
		var inner := {}
		for c in w.keys():
			inner[str(c)] = w.get_card(c)
		out[str(id)] = inner
	return out


func _deserialize_action_card_collection(data: Dictionary, target: Dictionary) -> void:
	for k in data:
		var w: ActionCardWallet = target[int(k)]
		for c in data[k]:
			w.set_card(int(c) as Model.ActionCardTypes, int(data[k][c]))


func _serialize_ports() -> Dictionary:
	var out := {}
	for k in _ports: out[k] = _ports[k]
	return out


func _deserialize_ports(data: Dictionary) -> void:
	_ports.clear()
	for k in data: _ports[k] = int(data[k]) as Model.ResourceTypes