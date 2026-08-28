class_name MainService
extends Node

const RES = Model.ResourceTypes
const GamePhase = Model.GamePhase

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
	EventBus.request_purchase_action_card.connect(self._on_request_purchase_action_card)
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

func _request_update_phase(phase: GamePhase):
	Game.model.do_update_phase(phase)


func _request_house(id: int, corner: Axial) -> void:
	var count = Game.model.get_houses(id).size()		

	if Game.model.get_current_phase() == Model.GamePhase.SETUP:
		if count == 1: self._award_resources(id, corner)
		Game.model.do_set_initial_house(id, corner)
	else:
		Game.model.do_remove_resources(id, Model.COSTS["house"])
		Game.model.do_set_house(id, corner)		


func _request_city(id: int, corner: Axial) -> void:
	Game.model.do_remove_resources(id, Model.COSTS["city"])
	Game.model.do_set_city(id, corner)


func _request_road(id: int, edge: AxialEdge) -> void:	
	if Game.model.get_current_phase() == GamePhase.ROAD_BUILDING:
		Game.model.decrement_road_building()
		if Game.model.free_road_count() == 0: Game.model.do_update_phase(GamePhase.MAIN)
	elif Game.model.get_current_phase() == Model.GamePhase.SETUP:
		self._next_initial_player(id)
	else:
		Game.model.do_remove_resources(id, Model.COSTS["road"])

	Game.model.do_set_road(id, edge)		
		

func _next_initial_player(id: int):
	var count_houses = Game.model.get_houses(id).size()	
	var next_player = id

	if count_houses == 1: # forward	
		next_player = next_player + 1
		if next_player > 3: next_player = 3
		Game.model.do_update_player(next_player)
	else: # reverse
		next_player = next_player - 1
		if next_player < 0:
			Game.model.do_update_player(0)
			Game.model.do_update_phase(GamePhase.MAIN)
			self._on_request_roll()
		else:
			Game.model.do_update_player(next_player)


func _request_add_action_card(id: int, c: Model.ActionCardTypes) -> void:
	Game.model.do_add_action_card(id, c)


func _request_set_pirate(_id: int, hex: Axial):	
	if hex.equals(Game.model.get_pirate()):
		Game.model.do_set_pirate(hex)
		return

	Game.model.do_set_pirate(hex)

	var corners := hex.corners()
	var buildings := corners.intersect(Game.model.get_all_buildings())

	for ax:Axial in buildings:
		var corner_owner = Game.model.get_owner(ax)
		if corner_owner == -1: continue
		if corner_owner == Game.self_id: continue
		Game.model.do_update_phase(GamePhase.STEAL_RESOURCES)
		return

	EventBus.notify.emit(Game.model.get_current_player(), "No players to steal from")
	Game.model.do_update_phase(GamePhase.MAIN)


func _request_play_action_card(id: int, card: Model.ActionCardTypes) -> void:
	Game.model.do_remove_action_card(id, card)

	match card:
		Model.ActionCardTypes.SOLDIER:			
			Game.model.do_update_phase(GamePhase.MOVE_PIRATE)
		Model.ActionCardTypes.BUILD_ROAD:
			Game.model.reset_road_building()
			Game.model.do_update_phase(GamePhase.ROAD_BUILDING)
		Model.ActionCardTypes.PLENTY:
			Game.model.do_update_phase(GamePhase.YEAR_OF_PLENTY)
		Model.ActionCardTypes.MONOPOLY:
			Game.model.do_update_phase(GamePhase.MONOPOLY)
		Model.ActionCardTypes.VICTORY_POINTS:
			Game.model.do_add_victory_point(id)


func _play_monopoly_card(id: int, resource: Model.ResourceTypes):
	for p in Game.player_count:
		if p == id: continue
		var bank := Game.model.get_bank(p)
		bank.keep_only(resource)
		Game.model.do_add_resources(id, bank)
		Game.model.do_remove_resources(p, bank)
	
	Game.model.do_update_phase(GamePhase.MAIN)


func _play_plenty_card(id: int, wallet: Wallet):
	Game.model.do_add_resources(id, wallet)
	Game.model.do_update_phase(GamePhase.MAIN)


func _play_road_building_card(id: int, roads: AxialEdgeSet) -> void:
	for axe in roads:
		Game.model.do_set_road(id, axe)


func _on_service_error(id: int, msg: String) -> void:
	push_error("service error from id=%s: %s" % [id, msg])


func request_exchange(id: int, from: Model.ResourceTypes, to: Model.ResourceTypes) -> void:
	var rate = Game.model.get_exchange_rate(Game.self_id).get_resource(from)
	var count = Game.model.get_bank(Game.self_id).get_resource(from)
	if count < rate: return

	var from_array: Array[Model.ResourceTypes] = []
	from_array.resize(rate)
	from_array.fill(from)

	Game.model.do_remove_resources(id, Wallet.new(from_array))
	Game.model.do_add_resources(id, Wallet.new([to]))

# called by the game in production
func _on_request_roll(d1: int = 0, d2: int = 0) -> void:
	if d1 == 0: d1 = randi_range(1, 6)
	if d2 == 0: d2 = randi_range(1, 6)

	Game.model.do_set_dice(d1, d2)

	if d1 + d2 == 7:
		Game.model.update_discard_targets()

		if DiscardService.is_pending():
			Game.model.do_update_phase(Model.GamePhase.DISCARD)
		else:
			Game.model.do_update_phase(Model.GamePhase.MOVE_PIRATE)		
		return

	for id in range(Game.player_count):	
		var resources := Wallet.new()
		self._scan_houses(id, d1 + d2, resources)
		self._scan_cities(id, d1 + d2, resources)
		EventBus.resources_received.emit(id, resources)
		Game.model.do_add_resources(id, resources)

	Game.model.do_update_phase(GamePhase.MAIN)

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
	var next = Game.model.get_current_player() + 1
	Game.model.do_update_player(next)
	Game.model.do_update_phase(GamePhase.MAIN)


func _award_resources(id:int, corner: Axial) -> void:
	var payout := Wallet.new()

	for hex: Axial in corner.hexes():
		var hexdata = Game.model.get_hex_data(hex)
		if hexdata.resource == Model.ResourceTypes.NONE: continue
		payout.add_resource(hexdata.resource)

	Game.model.do_add_resources(id, payout)


## Static helper to get neighbors of a given Axial.
static func resources_of(ax: Axial) -> AxialSet:
	return ax.neighbors()
