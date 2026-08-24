class_name BotBasic
extends RefCounted

var _game_model: Model
var _resource_counts := Wallet.new()
var id: int

# unique resource weights
var resource_w: Dictionary[Model.ResourceTypes, int] = {
	Model.ResourceTypes.WOOD: 30,
	Model.ResourceTypes.BRICK: 30,
	Model.ResourceTypes.WHEAT: 25,
	Model.ResourceTypes.ROCK: 20,
	Model.ResourceTypes.WOOL: 25
}

# port weights
var port_w: Dictionary[Model.ResourceTypes, int] = {
	Model.ResourceTypes.NONE: 0,
	Model.ResourceTypes.WOOD: 0,
	Model.ResourceTypes.BRICK: 0,
	Model.ResourceTypes.WHEAT: 0,
	Model.ResourceTypes.ROCK: 0,
	Model.ResourceTypes.WOOL: 0,
	Model.ResourceTypes.ANY: 25
}

# weight for numbers
var number_w: Dictionary[int, int] = {
	2: 0,
	3: 10,
	4: 20,
	5: 40,
	6: 80,
	8: 80,
	9: 40,
	10: 20,
	11: 10,
	12: 0
}

# weight for distance (number of roads to build)
var distance_w: Dictionary[int, int] = {
	0: 30,
	1: 20,
	2: 5,
	3: 5,
	4: 0
}

var path_builder: PathBuilder = null
var port_w_delta: int = 10 # applied for each resource
var resource_w_delta: int = 5
var number_w_delta: int = 15


func distance_weight(distance: int) -> int:
	if distance_w.has(distance): return distance_w[distance]
	return 0

func _init(id: int) -> void:
	self.id = id


func pre_process(game_model: Model) -> void:
	self._game_model = game_model
	
	# record the resource counts of occupied tiles
	# adjust the weights for resource type and tile number
	self._resource_counts = Wallet.new()
	for corner in game_model.get_houses(self.id):
		for hex in corner.hexes():
			var hex_data := game_model.get_hex_data(hex)
			if hex_data.number == -1: continue
			self._resource_counts.add_resource(hex_data.resource)
			self.resource_w[hex_data.resource] -= self.resource_w_delta
			self.port_w[hex_data.resource] += self.port_w_delta


	for corner in game_model.get_cities(self.id):
		for hex in corner.hexes():
			var hex_data := game_model.get_hex_data(hex)
			if hex_data.number == -1: continue
			self._resource_counts.add_resource(hex_data.resource, 2)
			self.resource_w[hex_data.resource] -= (self.resource_w_delta * 2)
			self.port_w[hex_data.resource] += (self.port_w_delta * 2)

	# discourage repeat ports
	for corner in game_model.get_all_buildings(self.id):
		var port = game_model.get_port(corner)
		if port == Model.ResourceTypes.NONE: continue			
		self.port_w[port] = 0

	# build path_builder
	self.path_builder = PathBuilder.new().run(self._game_model, self.id)


func process(game_model: Model) -> void:
	self.pre_process(game_model)

	if self._game_model.get_current_phase() == Model.GamePhase.SETUP:
		self.phase_setup()
	elif self._game_model.get_current_phase() == Model.GamePhase.MAIN:
		self.phase_main()


func phase_setup() -> void:
	if self._game_model.get_placement_phase() == Model.PlacementPhase.HOUSE1:
		self.initial_house()
	elif self._game_model.get_placement_phase() == Model.PlacementPhase.ROAD1:
		self.initial_road()
	elif self._game_model.get_placement_phase() == Model.PlacementPhase.HOUSE2:
		self.initial_house()
	elif self._game_model.get_placement_phase() == Model.PlacementPhase.ROAD2:
		self.initial_road()


func phase_main() -> void:		
	var best_rank = 0
	var best_axial = null

	# Evaluate each valid corner that can accept a house
	var corners := self._game_model.playable_corners()
	for corner in corners:
		var rank = self.rank_corner(corner)
		var distance = self.path_builder.distances[corner.key()]
		rank = rank + self.distance_weight(distance)

		if rank > best_rank:
			best_rank = rank
			best_axial = corner

	var best_distance = self.path_builder.distances[best_axial.key()]
	print("Best Axial %s at distance %s" % [best_axial, best_distance])

	if best_distance == 0:
		self.try_buy_house(best_axial)
	else:
		var path = self.path_builder.paths[best_axial.key()]
		self.try_buy_road(path[0])


func try_buy_house(corner: Axial) -> bool:
	var wallet := self._game_model.get_bank(self.id)
	if wallet.has_resources(Model.COSTS["house"]):
		EventBus.request_house.emit(self.id, corner)
		return true
	
	return false


func try_buy_road(edge: AxialEdge) -> bool:
	var wallet := self._game_model.get_bank(self.id)
	if wallet.has_resources(Model.COSTS["road"]):
		EventBus.request_road.emit(self.id, edge)
		return true
	
	return false


func initial_road() -> void:
	var edges = self._game_model.get_initial_road_targets(self.id)
	var edge = edges.to_array().pick_random()
	EventBus.request_road.emit(self.id, edge)


func initial_house() -> void:
	var best_rank = 0
	var best_axial = null

	# check each empty corner and rank them
	for corner:Axial in self._game_model.playable_corners():
		var rank = self.rank_corner(corner)
		if rank > best_rank:
			best_rank = rank
			best_axial = corner

	assert (best_axial != null)
	EventBus.request_house.emit(self.id, best_axial)


func rank_corner(corner: Axial) -> int:
	var port = self._game_model.get_port(corner)
	var rank = self.port_w[port]

	for hex:Axial in corner.hexes():
		var hex_data := self._game_model.get_hex_data(hex)
		if hex_data.number == -1: continue

		# adjust rank for the number
		var hex_rank = self.number_w[hex_data.number]

		# adjust rank for the resource
		hex_rank = hex_rank + self.resource_w[hex_data.resource]

		# if the resource matches the port add the weight
		if hex_data.resource == port:
			hex_rank += self.port_w[port]

		rank += hex_rank		

	return rank


func build_end_points() -> Array[Axial]:
	var edges = self._game_model.get_roads(self.id)

	for pid in range(0, Game.player_count):
		if pid == self.id: continue
		var houses = Game.model.get_all_buildings(pid)
		edges = edges.difference(houses.edge_map())
	
	return edges.corner_map().to_array()


# only follow edges that are empty
# don't have an opposing building on either corner
func build_adj_table() -> Dictionary[String, AxialSet]:
	var adj:Dictionary[String, AxialSet] = {}

	for edge in self.followable_edges():
		adj[edge.ax1.key()].add_item(edge.ax2)
		adj[edge.ax2.key()].add_item(edge.ax1)

	return adj


func followable_edges() -> AxialEdgeSet:
	var edges = Game.model.playable_edges()

	for pid in range(0, Game.player_count):
		if pid == self.id: continue
		var houses = Game.model.get_all_buildings(pid)
		edges = edges.difference(houses.edge_map())	

	return edges
