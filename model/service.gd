class_name Service
extends Object


func _init() -> void:
	EventBus.request_roll.connect(self._on_request_roll)
	EventBus.request_purchase_action_card.connect(self._on_request_purchase_action_card)
	EventBus.request_initial_house.connect(self.place_initial_house)
	EventBus.request_initial_road.connect(self.place_initial_road)


func _on_request_roll() -> void:
	var d1: int = randi_range(1, 6)
	var d2: int = randi_range(1, 6)
	EventBus.set_dice.emit(d1, d2)	
	
	for id in range(Game.player_count):	
		var resources: Array[Model.ResourceTypes] = []
		self._scan_houses(id, d1 + d2, resources)
		self._scan_cities(id, d1 + d2, resources)
		EventBus.add_resources.emit(id, resources)


func _scan_houses(id:int, number:int, resources: Array[Model.ResourceTypes]):
	var houses := Game.model.get_houses(id)
	var hexes := houses.map(Axial.hexes_of)
	hexes = hexes.remove_item(Game.model.get_robber())

	for hex:Axial in hexes:
		var data := Game.model.get_hex_data(hex)
		if data.number != number: continue
		var resource := Game.model.TERRAIN_TO_RESOURCE[data.terrain]			
		resources.append(resource)


func _scan_cities(id:int, number:int, resources: Array[Model.ResourceTypes]):
	var cities := Game.model.get_cities(id)
	var hexes := cities.map(Axial.hexes_of)
	hexes = hexes.remove_item(Game.model.get_robber())

	for hex:Axial in hexes:
		var data := Game.model.get_hex_data(hex)
		if data.number != number: continue
		var resource := Game.model.TERRAIN_TO_RESOURCE[data.terrain]			
		resources.append(resource)
		resources.append(resource)


func _on_request_purchase_action_card() -> void:
	var cost: Array[Model.ResourceTypes] = [
		Model.ResourceTypes.ROCK,
		Model.ResourceTypes.WHEAT,
		Model.ResourceTypes.WOOL,
	]
	EventBus.remove_resources.emit(Game.self_id, cost)

	var card = weighted_random(Model.CARD_DISTRIBUTION)
	EventBus.add_action_card.emit(Game.self_id, card)


static func weighted_random(weights: Dictionary) -> Variant:
	var total := 0
	for key in weights:
		total += weights[key]

	var roll := randi_range(0, total - 1)
	var cumulative := 0
	for key in weights:
		cumulative += weights[key]
		if roll < cumulative:
			return key

	return weights.keys().back()

func _next_player() -> void:
	var next = Game.model.get_current_player()
	if Game.model.get_current_phase() == Model.GamePhase.SETUP_FORWARD_ROAD:
		next = next + 1
		if next > 3:
			EventBus.update_player_phase.emit(3, Model.GamePhase.SETUP_REVERSE_HOUSE)
		else:
			EventBus.update_player_phase.emit(next, Model.GamePhase.SETUP_FORWARD_HOUSE)

	elif Game.model.get_current_phase() == Model.GamePhase.SETUP_REVERSE_ROAD:
		next = next - 1
		if next < 0:
			EventBus.update_player_phase.emit(0, Model.GamePhase.MAIN)
		else:
			EventBus.update_player_phase.emit(next, Model.GamePhase.SETUP_REVERSE_HOUSE)


func place_house(id: int, corner: Axial) -> void:
	EventBus.set_house.emit(id, corner)


func place_initial_house(id: int, corner: Axial) -> void:
	assert(id >= 0 and id <= 3, "Player id out of range: %s" % id)
	assert(not corner.is_hex(), "Axial is not a corner: %s" % corner)

	EventBus.set_house.emit(id, corner)

	if Game.model.get_current_phase() == Model.GamePhase.SETUP_REVERSE_HOUSE:
		var hexes = corner.hexes()

		var payout: Array[Model.ResourceTypes] = []
		for hex: Axial in hexes:
			payout.append(self.get_resource(hex))

		EventBus.add_resources.emit(id, payout)
		EventBus.update_player_phase.emit(Game.model.get_current_player(), Model.GamePhase.SETUP_REVERSE_ROAD)
	else:
		EventBus.update_player_phase.emit(Game.model.get_current_player(), Model.GamePhase.SETUP_FORWARD_ROAD)


func place_initial_road(id: int, edge: AxialEdge) -> void:
	EventBus.set_road.emit(id, edge)
	self._next_player()


func get_resource(ax: Axial) -> Model.ResourceTypes:
	return Game.model.get_hex_data(ax).resource
