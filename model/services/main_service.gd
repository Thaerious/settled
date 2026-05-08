class_name MainService
extends Node

const EXCHANGABLE = [
	Model.ResourceTypes.BRICK,
	Model.ResourceTypes.WOOD,
	Model.ResourceTypes.WHEAT,
	Model.ResourceTypes.WOOL,
	Model.ResourceTypes.ROCK
]


func _ready() -> void:
	# Sub-Services
	self.add_child(DiscardService.new())

	# Listeners
	EventBus.service_error.connect(self._on_service_error)
	EventBus.request_roll.connect(self._on_request_roll)
	EventBus.specify_roll.connect(self._do_roll)
	EventBus.request_purchase_action_card.connect(self._on_request_purchase_action_card)
	EventBus.request_initial_house.connect(self.place_initial_house)
	EventBus.request_initial_road.connect(self.place_initial_road)
	EventBus.request_exchange.connect(self.request_exchange)


	EventBus.request_play_action_card.connect(self._request_play_action_card)
	EventBus.play_monopoly_card.connect(self._play_monopoly_card)
	EventBus.play_plenty_card.connect(self._play_plenty_card)
	EventBus.play_road_building_card.connect(self._play_road_building_card)

	EventBus.request_set_pirate.connect(self._request_set_pirate)


func _request_set_pirate(_id: int, hex: Axial):
	EventBus.set_pirate.emit(hex)

	var corners := hex.corners()
	var buildings := corners.intersect(Game.model.get_all_buildings())

	for ax:Axial in buildings:
		var corner_owner = Game.model.get_owner(ax)
		if corner_owner == -1: continue
		if corner_owner == Game.self_id: continue
		EventBus.update_phase.emit(Model.GamePhase.STEAL_RESOURCES)
		return

	EventBus.update_phase.emit(Model.GamePhase.MAIN)


func _request_play_action_card(id: int, card: Model.ActionCardTypes) -> void:
	EventBus.remove_action_card.emit(id, card)
	
	match card:
		Model.ActionCardTypes.SOLDIER:			
			EventBus.update_phase.emit(Model.GamePhase.MOVE_PIRATE)
		Model.ActionCardTypes.BUILD_ROAD:
			EventBus.update_phase.emit(Model.GamePhase.ROAD_BUILDING)
		Model.ActionCardTypes.PLENTY:
			EventBus.update_phase.emit(Model.GamePhase.YEAR_OF_PLENTY)
		Model.ActionCardTypes.MONOPOLY:
			EventBus.update_phase.emit(Model.GamePhase.MONOPOLY)
		Model.ActionCardTypes.VICTORY_POINTS:
			EventBus.add_victory_point.emit(id)


func _play_monopoly_card(id: int, resource: Model.ResourceTypes):
	for p in Game.player_count:
		if p == id: continue
		var bank := Game.model.get_bank(p)
		bank.keep(resource)
		EventBus.add_resources.emit(id, bank)
		EventBus.remove_resources.emit(p, bank)
	
	EventBus.update_phase.emit(Model.GamePhase.MAIN)


func _play_plenty_card(id: int, wallet: Wallet):
	EventBus.add_resources.emit(id, wallet)
	EventBus.update_phase.emit(Model.GamePhase.MAIN)


func _play_road_building_card(id: int, roads: AxialEdgeSet) -> void:
	for axe in roads:
		EventBus.set_road.emit(id, axe)


func _on_service_error(id: int, msg: String) -> void:
	push_error("service error from id=%s: %s" % [id, msg])


func request_exchange(id: int, from: Model.ResourceTypes, to: Model.ResourceTypes) -> void:
	var rate = Game.model.get_exchange_rate(Game.self_id, from)
	var count = Game.model.get_bank(Game.self_id).get_resource(from)
	if count < rate: return

	var from_array: Array[Model.ResourceTypes] = []
	from_array.resize(rate)
	from_array.fill(from)

	EventBus.remove_resources.emit(id, from_array)
	EventBus.add_resources.emit(id, Wallet.new([to]))

func _on_request_roll() -> void:
	var d1: int = randi_range(1, 6)
	var d2: int = randi_range(1, 6)
	self._do_roll(d1, d2)


func _do_roll(d1: int, d2: int) -> void:
	EventBus.set_dice.emit(d1, d2)
	if d1 + d2 == 7:
		EventBus.update_phase.emit(Model.GamePhase.DISCARD)
		return

	for id in range(Game.player_count):	
		var resources := Wallet.new()
		self._scan_houses(id, d1 + d2, resources)
		self._scan_cities(id, d1 + d2, resources)
		EventBus.add_resources.emit(id, resources)


func _scan_houses(id:int, number:int, resources: Wallet):
	var houses := Game.model.get_houses(id)
	var hexes := houses.map(Axial.hexes_of)
	hexes = hexes.remove_item(Game.model.get_pirate())

	for hex:Axial in hexes:
		var data := Game.model.get_hex_data(hex)
		if data.number != number: continue
		var resource := Game.model.TERRAIN_TO_RESOURCE[data.terrain]			
		resources.add_resource(resource)


func _scan_cities(id:int, number:int, resources: Wallet):
	var cities := Game.model.get_cities(id)
	var hexes := cities.map(Axial.hexes_of)
	hexes = hexes.remove_item(Game.model.get_pirate())

	for hex:Axial in hexes:
		var data := Game.model.get_hex_data(hex)
		if data.number != number: continue
		var resource := Game.model.TERRAIN_TO_RESOURCE[data.terrain]			
		resources.add_resource(resource)
		resources.add_resource(resource)


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
			EventBus.update_player.emit(3)
			EventBus.update_phase.emit(Model.GamePhase.SETUP_REVERSE_HOUSE)
		else:
			EventBus.update_player.emit(next)
			EventBus.update_phase.emit(Model.GamePhase.SETUP_FORWARD_HOUSE)

	elif Game.model.get_current_phase() == Model.GamePhase.SETUP_REVERSE_ROAD:
		next = next - 1
		if next < 0:
			EventBus.update_player.emit(0)
			EventBus.update_phase.emit(Model.GamePhase.MAIN)
		else:
			EventBus.update_player.emit(next)
			EventBus.update_phase.emit(Model.GamePhase.SETUP_REVERSE_HOUSE)


func place_house(id: int, corner: Axial) -> void:
	EventBus.set_house.emit(id, corner)
	var port_resource = Game.model.get_port(corner)

	if port_resource == Model.ResourceTypes.ANY:
		for r in EXCHANGABLE:
			if Game.model.get_exchange_rate(id, r) > 3:
				EventBus.set_exchange_rate.emit(id, r, 3)
	elif port_resource != Model.ResourceTypes.NONE:
		if Game.model.get_exchange_rate(id, port_resource) > 2:
			EventBus.set_exchange_rate.emit(id, port_resource, 2)


func place_initial_house(id: int, corner: Axial) -> void:
	assert(id >= 0 and id <= 3, "Player id out of range: %s" % id)
	assert(not corner.is_hex(), "Axial is not a corner: %s" % corner)

	self.place_house(id, corner)

	if Game.model.get_current_phase() == Model.GamePhase.SETUP_REVERSE_HOUSE:
		var payout := Wallet.new()

		for hex: Axial in corner.hexes():
			var hexdata = Game.model.get_hex_data(hex)
			if hexdata.resource == Model.ResourceTypes.NONE: continue
			payout.add_resource(hexdata.resource)

		EventBus.add_resources.emit(id, payout)
		EventBus.update_phase.emit(Model.GamePhase.SETUP_REVERSE_ROAD)
	else:
		EventBus.update_phase.emit(Model.GamePhase.SETUP_FORWARD_ROAD)


func place_initial_road(id: int, edge: AxialEdge) -> void:
	EventBus.set_road.emit(id, edge)
	self._next_player()


func get_resource(ax: Axial) -> Model.ResourceTypes:
	return Game.model.get_hex_data(ax).resource
