class_name Service
extends Object


func _init() -> void:
	EventBus.request_roll.connect(self._on_request_roll)
	EventBus.request_purchase_action_card.connect(self._on_request_purchase_action_card)


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

	
