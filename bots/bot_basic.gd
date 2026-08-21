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

# weight for numbers
var number_w: Dictionary[int, float] = {
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

var resouce_w_delta: int = 5
var number_w_delta: int = 15


func _init(id: int) -> void:
	self.id = id


func pre_process(game_model: Model) -> void:
	self._game_model = game_model
	
	# record the resouce counts of occupied tiles
	# adjust the weights for resource type and tile number
	self._resource_counts = Wallet.new()
	for corner in game_model.get_houses(self.id):
		for hex in corner.hexes():
			var hex_data := game_model.get_hex_data(hex)
			self._resource_counts.add_resource(hex_data.resource)
			self.resource_w[hex_data.resouce] -= self.resource_w_delta

	for corner in game_model.get_cities(self.id):
		for hex in corner.hexes():
			var hex_data := game_model.get_hex_data(hex)
			self._resource_counts.add_resource(hex_data.resource, 2)
			self.resource_w[hex_data.resouce] -= (self.resource_w_delta * 2)


func process(game_model: Model) -> void:
	self.pre_process(game_model)

	assert(game_model.get_placement_phase() != Model.PlacementPhase.NONE)

	if game_model.get_placement_phase() == Model.PlacementPhase.HOUSE1:
		self.initial_house()
	elif game_model.get_placement_phase() == Model.PlacementPhase.ROAD1:
		self.initial_road()
	elif game_model.get_placement_phase() == Model.PlacementPhase.HOUSE2:
		self.initial_house()
	elif game_model.get_placement_phase() == Model.PlacementPhase.ROAD2:
		self.initial_road()


func initial_road() -> void:
	var edges = self._game_model.get_initial_road_targets(self.id)
	var edge = edges.to_array().pick_random()
	print("Bot Action: request_road | AxialEdge: %s" % [edge])
	EventBus.request_road.emit(self.id, edge)


func initial_house() -> void:
	var best_rank = 0
	var best_axial = null

	# check each empty corner and rank them
	for corner:Axial in self.buildable_corners():
		var rank = self.rank_initial(corner)
		print(" - rank: %s" % [corner, rank])
		if rank > best_rank:
			best_rank = rank
			best_axial = corner

	assert (best_axial != null)
	print("Bot Action: request_house | Axial: %s" % [best_axial])
	EventBus.request_house.emit(self.id, best_axial)


func rank_initial(corner: Axial) -> int:
	var rank = 0

	for hex:Axial in corner.hexes():
		var hex_data := self._game_model.get_hex_data(hex)
		if hex_data.number == -1: continue

		# adjust rank for the number
		var hex_rank = self.number_w[hex_data.number]

		# adjust rank for the resouce
		hex_rank = hex_rank + self.resource_w[hex_data.resource]
		
		rank += hex_rank		

	return rank


func buildable_corners() -> AxialSet:
	var buildable_corners := AxialSet.new()

	for hex_data: HexData in self._game_model.all_hex_data():
		if hex_data.terrain == Model.Terrain.WATER: continue
		buildable_corners.add_all(hex_data.axial.corners())

	var houses = self._game_model.get_all_buildings()
	var neighbors := houses.map(Axial.neighbors_of)
	houses = houses.add_all(neighbors)
	return buildable_corners.difference(houses)
	
