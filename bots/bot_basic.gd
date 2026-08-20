class_name BotBasic
extends RefCounted

var _game_model: Model
var _resource_counts := Wallet.new()
var id: int

# unique resource weights
var uni_res_w: Dictionary[Model.ResourceTypes, int] = {
	Model.ResourceTypes.WOOD: 2,
	Model.ResourceTypes.BRICK: 2,
	Model.ResourceTypes.WHEAT: 2,
	Model.ResourceTypes.ROCK: 2,
	Model.ResourceTypes.WOOL: 2
}

# repeat resource weights
var rep_res_w: Dictionary[Model.ResourceTypes, int] = {
	Model.ResourceTypes.WOOD: 1,
	Model.ResourceTypes.BRICK: 1,
	Model.ResourceTypes.WHEAT: 1,
	Model.ResourceTypes.ROCK: 1,
	Model.ResourceTypes.WOOL: 1
}

# weight for numbers
var number_w: Dictionary[int, float] = {
	2: 0,
	3: 1,
	4: 1,
	5: 2,
	6: 2.5,
	8: 2.5,
	9: 2,
	10: 1,
	11: 1,
	12: 0
}


func _init(id: int) -> void:
	self.id = id


func process(game_model: Model) -> void:
	self._game_model = game_model

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

	# check each edge and rank them
	for corner:Axial in self.buildable_corners():
		print("Considering corner axial: %s" % [corner])
		var rank = self.rank_initial(corner)
		print("Calculated rank for axial: %s | rank: %s" % [corner, rank])
		if rank > best_rank:
			best_rank = rank
			best_axial = corner

	assert (best_axial != null)
	print("Bot Action: request_house | Axial: %s" % [best_axial])
	EventBus.request_house.emit(self.id, best_axial)


func rank_initial(corner: Axial) -> int:
	var rank = 0
	var wallet := Game.model.resources_of(corner)
	for resource in wallet:
		rank = rank + uni_res_w[resource]

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
	
