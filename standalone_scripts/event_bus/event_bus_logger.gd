## event_bus_logger.gd
class_name EventBusLogger
extends Node


func _ready() -> void:
	print("Connecting Event Bus Logger")

	EventBus.show_house_targets.connect(func(): print("EventBus.show_house_targets"))
	EventBus.show_initial_house_targets.connect(func(): print("EventBus.show_initial_house_targets"))
	EventBus.show_initial_road_targets.connect(func(house_axial: Axial): print("EventBus.show_initial_road_targets | house_axial: %s" % [house_axial]))
	EventBus.show_city_targets.connect(func(): print("EventBus.show_city_targets"))
	EventBus.show_road_targets.connect(func(): print("EventBus.show_road_targets"))
	EventBus.clear_targets.connect(func(): print("EventBus.clear_targets"))

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

	EventBus.play_monopoly_card.connect(func(id: int, resource: Model.ResourceTypes): print("EventBus.play_monopoly_card | id: %s | resource: %s" % [id, Model.ResourceTypes.find_key(resource)]))
	EventBus.play_plenty_card.connect(func(id: int, resources: Wallet): print("EventBus.play_plenty_card | id: %s | resources: %s" % [id, resources]))
	EventBus.play_victory_card.connect(func(id: int): print("EventBus.play_victory_card | id: %s" % [id]))
	EventBus.play_soldier_card.connect(func(id: int): print("EventBus.play_soldier_card | id: %s" % [id]))
	EventBus.play_road_building_card.connect(func(id: int): print("EventBus.play_road_building_card | id: %s" % [id]))

	EventBus.discard_resources.connect(func(id: int, discard: Wallet): print("EventBus.discard_resources | id: %s | discard: %s" % [id, discard]))
	EventBus.update_player.connect(func(current_player: int): print("EventBus.update_player | current_player: %s" % [current_player]))
	EventBus.update_phase.connect(func(phase: Model.GamePhase): print("EventBus.update_phase | phase: %s" % [Model.GamePhase.find_key(phase)]))

	EventBus.set_dice.connect(func(d1: int, d2: int): print("EventBus.set_dice | d1: %s | d2: %s" % [d1, d2]))
	EventBus.add_resources.connect(func(id: int, wallet: Wallet): print("EventBus.add_resources | id: %s | wallet: %s" % [id, wallet]))
	EventBus.remove_resources.connect(func(id: int, wallet: Wallet): print("EventBus.remove_resources | id: %s | wallet: %s" % [id, wallet]))
	EventBus.update_action_card.connect(func(id: int, cards: ActionCardsContainer): print("EventBus.update_action_card | id: %s | cards: %s" % [id, cards]))
	EventBus.update_victory_points.connect(func(id: int, delta: int): print("EventBus.update_victory_points | id: %s | delta: %s" % [id, delta]))
	EventBus.update_longest_road.connect(func(id: int): print("EventBus.update_longest_road | id: %s" % [id]))
	EventBus.update_largest_army.connect(func(id: int): print("EventBus.update_largest_army | id: %s" %[id]))
	EventBus.reset_view.connect(func(): print("EventBus.reset_view"))

	EventBus.set_house.connect(func(id: int, corner: Axial): print("EventBus.set_house | id: %s | corner: %s" % [id, corner]))
	EventBus.set_city.connect(func(id: int, corner: Axial): print("EventBus.set_city | id: %s | corner: %s" % [id, corner]))
	EventBus.set_road.connect(func(id: int, edge: AxialEdge): print("EventBus.set_road | id: %s | edge: %s" % [id, edge]))
	EventBus.set_exchange_rate.connect(func(id: int, r: Model.ResourceTypes, value: int): print("EventBus.set_exchange_rate | id: %s | r: %s | value: %s" % [id, Model.ResourceTypes.find_key(r), value]))
	EventBus.set_pirate.connect(func(hex: Axial): print("EventBus.set_pirate | hex: %s" % [hex]))
	EventBus.add_victory_point.connect(func(id: int): print("EventBus.add_victory_point | id: %s" % [id]))
	EventBus.add_soldier.connect(func(id: int): print("EventBus.add_soldier | id: %s" % [id]))
	EventBus.add_action_card.connect(func(id: int, c: Model.ActionCardTypes): print("EventBus.add_action_card | id: %s | c: %s" % [id, Model.ActionCardTypes.find_key(c)]))
	EventBus.remove_action_card.connect(func(id: int, c: Model.ActionCardTypes): print("EventBus.remove_action_card | id: %s | c: %s" % [id, Model.ActionCardTypes.find_key(c)]))
	EventBus.set_action_cards.connect(func(id: int, ac_wallet: ActionCardWallet): print("EventBus.set_action_cards | id: %s | ac_wallet: %s" % [id, ac_wallet]))

	EventBus.set_player_view.connect(func(id: int): print("EventBus.set_player_view | id: %s" % [id]))
	EventBus.save_model_state.connect(func(): print("EventBus.save_model_state"))
	EventBus.load_model_state.connect(func(): print("EventBus.load_model_state"))
	EventBus.specify_roll.connect(func(d1: int, d2: int): print("EventBus.specify_roll | d1: %s | d2: %s" % [d1, d2]))

	EventBus.service_error.connect(func(id: int, msg: String): print("EventBus.service_error | id: %s | msg: %s" % [id, msg]))
	