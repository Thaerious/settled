class_name MainService
extends Node

const RES = Model.ResourceTypes

const EXCHANGABLE = [
	Model.ResourceTypes.BRICK,
	Model.ResourceTypes.WOOD,
	Model.ResourceTypes.WHEAT,
	Model.ResourceTypes.WOOL,
	Model.ResourceTypes.ROCK
]

func _ready() -> void:
	# Sub-Services
	Game.model = Game.model
	self.add_child(DiscardService.new())
	self.add_child(StealService.new())

	# Listeners
	EventBus.service_error.connect(self._on_service_error)
	EventBus.request_roll.connect(self._on_request_roll)
	EventBus.development_roll.connect(self._development_roll)
	EventBus.request_purchase_action_card.connect(self._on_request_purchase_action_card)
	EventBus.request_initial_house.connect(self.place_initial_house)
	EventBus.request_initial_road.connect(self.place_initial_road)
	EventBus.request_exchange.connect(self.request_exchange)
	EventBus.request_play_action_card.connect(self._request_play_action_card)
	EventBus.play_monopoly_card.connect(self._play_monopoly_card)
	EventBus.play_plenty_card.connect(self._play_plenty_card)
	EventBus.play_road_building_card.connect(self._play_road_building_card)
	EventBus.request_set_pirate.connect(self._request_set_pirate)
	EventBus.request_add_action_card.connect(self._request_add_action_card) 
	EventBus.request_house.connect(self._request_house)
	EventBus.request_city.connect(self._request_city)
	EventBus.request_road.connect(self._request_road)
	EventBus.request_update_phase.connect(self._request_update_phase)
	EventBus.request_end_turn.connect(self._request_end_turn)	


func _request_end_turn() -> void:
	Game.model.do_end_turn()

func _request_update_phase(phase: Model.GamePhase):
	Game.model.do_update_phase(phase)


func _request_house(id: int, corner: Axial) -> void:
	Game.model.do_remove_resources(id, Model.COSTS["house"])
	Game.model.do_set_house(id, corner)


func _request_city(id: int, corner: Axial) -> void:
	Game.model.do_remove_resources(id, Model.COSTS["city"])
	Game.model.do_set_city(id, corner)


func _request_road(id: int, edge: AxialEdge) -> void:
	Game.model.do_remove_resources(id, Model.COSTS["road"])
	Game.model.do_set_road(id, edge)


func _request_add_action_card(id: int, c: Model.ActionCardTypes) -> void:
	Game.model.do_add_action_card(id, c)


func _request_set_pirate(_id: int, hex: Axial):
	Game.model.do_set_pirate(hex)

	var corners := hex.corners()
	var buildings := corners.intersect(Game.model.get_all_buildings())

	for ax:Axial in buildings:
		var corner_owner = Game.model.get_owner(ax)
		if corner_owner == -1: continue
		if corner_owner == Game.self_id: continue
		Game.model.do_update_phase(Model.GamePhase.STEAL_RESOURCES)
		return

	Game.model.do_update_phase(Model.GamePhase.MAIN)


func _request_play_action_card(id: int, card: Model.ActionCardTypes) -> void:
	Game.model.do_remove_action_card(id, card)
	
	match card:
		Model.ActionCardTypes.SOLDIER:			
			Game.model.do_update_phase(Model.GamePhase.MOVE_PIRATE)
		Model.ActionCardTypes.BUILD_ROAD:
			Game.model.do_update_phase(Model.GamePhase.ROAD_BUILDING)
		Model.ActionCardTypes.PLENTY:
			Game.model.do_update_phase(Model.GamePhase.YEAR_OF_PLENTY)
		Model.ActionCardTypes.MONOPOLY:
			Game.model.do_update_phase(Model.GamePhase.MONOPOLY)
		Model.ActionCardTypes.VICTORY_POINTS:
			Game.model.do_add_victory_point(id)


func _play_monopoly_card(id: int, resource: Model.ResourceTypes):
	for p in Game.player_count:
		if p == id: continue
		var bank := Game.model.get_bank(p)
		bank.keep(resource)
		Game.model.do_add_resources(id, bank)
		Game.model.do_remove_resources(p, bank)
	
	Game.model.do_update_phase(Model.GamePhase.MAIN)


func _play_plenty_card(id: int, wallet: Wallet):
	Game.model.do_add_resources(id, wallet)
	Game.model.do_update_phase(Model.GamePhase.MAIN)


func _play_road_building_card(id: int, roads: AxialEdgeSet) -> void:
	for axe in roads:
		Game.model.do_set_road(id, axe)


func _on_service_error(id: int, msg: String) -> void:
	push_error("service error from id=%s: %s" % [id, msg])


func request_exchange(id: int, from: Model.ResourceTypes, to: Model.ResourceTypes) -> void:
	var rate = Game.model.get_exchange_rate(Game.self_id, from)
	var count = Game.model.get_bank(Game.self_id).get_resource(from)
	if count < rate: return

	var from_array: Array[Model.ResourceTypes] = []
	from_array.resize(rate)
	from_array.fill(from)

	Game.model.do_remove_resources(id, Wallet.new(from_array))
	Game.model.do_add_resources(id, Wallet.new([to]))


# called by the game in production
func _on_request_roll() -> void:
	var d1: int = randi_range(1, 6)
	var d2: int = randi_range(1, 6)
	self._development_roll(d1, d2)


# called by the game in development
func _development_roll(d1: int, d2: int) -> void:
	Game.model.do_set_dice(d1, d2)
	if d1 + d2 == 7:
		Game.model.do_update_phase(Model.GamePhase.INIT_DISCARD)
		return

	for id in range(Game.player_count):	
		var resources := Wallet.new()
		self._scan_houses(id, d1 + d2, resources)
		self._scan_cities(id, d1 + d2, resources)
		Game.model.do_add_resources(id, resources)


func _scan_houses(id:int, number:int, resources: Wallet):
	var houses := Game.model.get_houses(id)

	for house in houses:
		for hex in house.hexes():
			if hex.equals(Game.model.get_pirate()): continue
			var data = Game.model.get_hex_data(hex)
			if data.number != number: continue
			resources.add_resource(data.resource)


func _scan_cities(id:int, number:int, resources: Wallet):
	var cities := Game.model.get_cities(id)

	for house in cities:
		for hex in house.hexes():
			if hex.equals(Game.model.get_pirate()): continue
			var data = Game.model.get_hex_data(hex)
			if data.number != number: continue
			resources.add_resource(data.resource, 2)


func _on_request_purchase_action_card() -> void:
	Game.model.do_remove_resources(Game.self_id, Model.COSTS["card"])
	var card = weighted_random(Model.CARD_DISTRIBUTION)
	Game.model.do_add_action_card(Game.self_id, card)


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
			Game.model.do_update_player(3)
			Game.model.do_update_phase(Model.GamePhase.SETUP_REVERSE_HOUSE)
		else:
			Game.model.do_update_player(next)
			Game.model.do_update_phase(Model.GamePhase.SETUP_FORWARD_HOUSE)

	elif Game.model.get_current_phase() == Model.GamePhase.SETUP_REVERSE_ROAD:
		next = next - 1
		if next < 0:
			Game.model.do_update_player(0)
			Game.model.do_update_phase(Model.GamePhase.MAIN)
		else:
			Game.model.do_update_player(next)
			Game.model.do_update_phase(Model.GamePhase.SETUP_REVERSE_HOUSE)


func place_house(id: int, corner: Axial) -> void:
	Game.model.do_set_house(id, corner)
	var port_resource = Game.model.get_port(corner)

	if port_resource == Model.ResourceTypes.ANY:
		for r in EXCHANGABLE:
			if Game.model.get_exchange_rate(id, r) > 3:
				Game.model.do_set_exchange_rate(id, r, 3)
	elif port_resource != Model.ResourceTypes.NONE:
		if Game.model.get_exchange_rate(id, port_resource) > 2:
			Game.model.do_set_exchange_rate(id, port_resource, 2)


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

		Game.model.do_add_resources(id, payout)
		Game.model.do_update_phase(Model.GamePhase.SETUP_REVERSE_ROAD)
	else:
		Game.model.do_update_phase(Model.GamePhase.SETUP_FORWARD_ROAD)


func place_initial_road(id: int, edge: AxialEdge) -> void:
	Game.model.do_set_road(id, edge)
	self._next_player()


func get_resource(ax: Axial) -> Model.ResourceTypes:
	return Game.model.get_hex_data(ax).resource
