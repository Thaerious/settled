## event_bus_logger.gd
class_name EventBusLogger
extends Node


func _ready() -> void:
	EventBus.show_initial_house_targets.connect(func(): print("EventBus.show_initial_house_targets"))
	EventBus.show_initial_road_targets.connect(func(house_axial: Axial): print("EventBus.show_initial_road_targets | house_axial: %s" % [house_axial]))
	EventBus.show_house_targets.connect(func(): print("EventBus.show_house_targets"))
	EventBus.show_city_targets.connect(func(): print("EventBus.show_city_targets"))
	EventBus.show_road_targets.connect(func(): print("EventBus.show_road_targets"))
	EventBus.clear_targets.connect(func(): print("EventBus.clear_targets"))
	EventBus.set_road_view_only.connect(func(id: int, edge: AxialEdge): print("EventBus.set_road_view_only | id: %s | edge: %s" % [id, edge]))

	EventBus.request_roll.connect(func(): print("EventBus.request_roll"))
	EventBus.request_purchase_action_card.connect(func(): print("EventBus.request_purchase_action_card"))
	EventBus.request_play_action_card.connect(func(id: int, card: Model.ActionCardTypes): print("EventBus.request_play_action_card | id: %s | card: %s" % [id, Model.ActionCardTypes.find_key(card)]))
	EventBus.request_initial_house.connect(func(id: int, hex: Axial): print("EventBus.request_initial_house | id: %s | hex: %s" % [id, hex]))
	EventBus.request_initial_road.connect(func(id: int, edge: AxialEdge): print("EventBus.request_initial_road | id: %s | edge: %s" % [id, edge]))
	EventBus.request_house.connect(func(id: int, corner: Axial): print("EventBus.request_house | id: %s | corner: %s" % [id, corner]))
	EventBus.request_city.connect(func(id: int, corner: Axial): print("EventBus.request_city | id: %s | corner: %s" % [id, corner]))
	EventBus.request_road.connect(func(id: int, edge: AxialEdge): print("EventBus.request_road | id: %s | edge: %s" % [id, edge]))
	EventBus.request_exchange.connect(func(id: int, from: Model.ResourceTypes, to: Model.ResourceTypes): print("EventBus.request_exchange | id: %s | from: %s | to: %s" % [id, Model.ResourceTypes.find_key(from), Model.ResourceTypes.find_key(to)]))
	EventBus.request_set_pirate.connect(func(id: int, hex: Axial): print("EventBus.request_set_pirate | id: %s | hex: %s" % [id, hex]))
	EventBus.request_steal_from.connect(func(id: int): print("EventBus.request_steal_from | id: %s" % [id]))
	EventBus.request_update_phase.connect(func(phase: Model.GamePhase): print("EventBus.request_update_phase | phase: %s" % [Model.GamePhase.find_key(phase)]))
	EventBus.request_add_action_card.connect(func(id: int, c: Model.ActionCardTypes): print("EventBus.request_add_action_card | id: %s | c: %s" % [id, Model.ActionCardTypes.find_key(c)]))
	EventBus.request_discard.connect(func(id: int, discard: Wallet): print("EventBus.request_discard | id: %s | discard: %s" % [id, discard]))
	EventBus.play_monopoly_card.connect(func(id: int, resource: Model.ResourceTypes): print("EventBus.play_monopoly_card | id: %s | resource: %s" % [id, Model.ResourceTypes.find_key(resource)]))
	EventBus.play_plenty_card.connect(func(id: int, resources: Wallet): print("EventBus.play_plenty_card | id: %s | resources: %s" % [id, resources]))
	EventBus.play_road_building_card.connect(func(id: int, roads: AxialEdgeSet): print("EventBus._play_road_building_card | id: %s | roads: %s" % [id, roads]))

	EventBus.update_longest_road.connect(func(id: int): print("EventBus.update_longest_road | id: %s" % [id]))
	EventBus.update_largest_army.connect(func(id: int): print("EventBus.update_largest_army | id: %s" % [id]))

	EventBus.model_loaded.connect(func(): print("EventBus.model_loaded"))
	EventBus.pirate_set.connect(func(hex: Axial): print("EventBus.pirate_set | hex: %s" % [hex]))
	EventBus.exchange_rate_set.connect(func(id: int, r: Model.ResourceTypes, value: int): print("EventBus.exchange_rate_set | id: %s | r: %s | value: %s" % [id, Model.ResourceTypes.find_key(r), value]))
	EventBus.current_player_updated.connect(func(current_player: int): print("EventBus.current_player_updated | current_player: %s" % [current_player]))
	EventBus.current_phase_updated.connect(func(phase: Model.GamePhase): print("EventBus.current_phase_updated | phase: %s" % [Model.GamePhase.find_key(phase)]))
	EventBus.action_cards_updated.connect(func(id: int, owned: ActionCardWallet, playable: ActionCardWallet): print("EventBus.action_cards_updated | id: %s | owned: %s | playable: %s" % [id, owned, playable]))
	EventBus.house_added.connect(func(id: int, corner: Axial): print("EventBus.house_added | id: %s | corner: %s" % [id, corner]))
	EventBus.city_added.connect(func(id: int, corner: Axial): print("EventBus.city_added | id: %s | corner: %s" % [id, corner]))
	EventBus.road_added.connect(func(id: int, edge: AxialEdge): print("EventBus.road_added | id: %s | edge: %s" % [id, edge]))
	EventBus.dice_set.connect(func(d1: int, d2: int): print("EventBus.dice_set | d1: %s | d2: %s" % [d1, d2]))
	EventBus.player_record_updated.connect(func(id: int, record: PlayerRecord): print("EventBus.player_record_updated | id: %s | record: %s" % [id, record]))
	EventBus.resources_updated.connect(func(id: int, wallet: Wallet): print("EventBus.resources_updated | id: %s | wallet: %s" % [id, wallet]))

	EventBus.set_player_view.connect(func(id: int): print("EventBus.set_player_view | id: %s" % [id]))
	EventBus.save_model_state.connect(func(): print("EventBus.save_model_state"))
	EventBus.load_model_state.connect(func(): print("EventBus.load_model_state"))
	EventBus.development_roll.connect(func(d1: int, d2: int): print("EventBus.development_roll | d1: %s | d2: %s" % [d1, d2]))

	EventBus.service_error.connect(func(id: int, msg: String): print("EventBus.service_error | id: %s | msg: %s" % [id, msg]))
	
