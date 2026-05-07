## event_bus_logger.gd
class_name EventBusLogger
extends Node


func _ready() -> void:
	print("EventBusLogger Ready")

	# View to view
	EventBus.show_house_targets.connect(func(): print("EventBus.show_house_targets"))
	EventBus.show_initial_house_targets.connect(func(): print("EventBus.show_initial_house_targets"))
	EventBus.show_initial_road_targets.connect(func(house_axial: Axial): print("EventBus.show_initial_road_targets | house_axial: %s" % house_axial))
	EventBus.show_city_targets.connect(func(): print("EventBus.show_city_targets"))
	EventBus.show_road_targets.connect(func(): print("EventBus.show_road_targets"))
	EventBus.clear_targets.connect(func(): print("EventBus.clear_targets"))
# 
	# View to service
	EventBus.request_roll.connect(func(): print("EventBus.request_roll"))
	EventBus.request_purchase_action_card.connect(func(): print("EventBus.request_purchase_action_card"))
	EventBus.request_play_action_card.connect(func(id: int, card: Model.ActionCardTypes): print("EventBus.play_action_card | id: %s | card: %s" % [id, card]))
	EventBus.request_initial_house.connect(func(id: int, hex: Axial): print("EventBus.place_initial_house | id: %s | hex: %s" % [id, hex]))
	EventBus.request_initial_road.connect(func(id: int, edge: AxialEdge): print("EventBus.place_initial_road | id: %s | edge: %s" % [id, edge]))

	# Model/Service to view
	EventBus.set_dice.connect(func(d1: int, d2: int): print("EventBus.set_dice | d1: %s | d2: %s" % [d1, d2]))
	EventBus.add_resources.connect(func(id: int, resources: Wallet): print("EventBus.add_resources | id: %s | resources: %s" % [id, resources]))
	EventBus.remove_resources.connect(func(id: int, resources: Wallet): print("EventBus.remove_resources | id: %s | resources: %s" % [id, resources]))
	EventBus.add_action_card.connect(func(id: int, card: Model.ActionCardTypes): print("EventBus.add_action_card | id: %s | card: %s" % [id, card]))
	EventBus.update_victory_points.connect(func(id: int, delta: int): print("EventBus.update_victory_points | id: %s | delta: %s" % [id, delta]))
	EventBus.update_longest_road.connect(func(id: int): print("EventBus.update_longest_road | id: %s" % id))
	EventBus.update_largest_army.connect(func(id: int): print("EventBus.update_largest_army | id: %s" % id))
	EventBus.update_player_phase.connect(func(current_player: int, phase: Model.GamePhase): print("EventBus.update_player_phase | current_player: %s | phase: %s" % [current_player, Model.GamePhase.find_key(phase)]))
	EventBus.reset_view.connect(func(): print("EventBus.reset_view"))
	EventBus.set_exchange_rate.connect(func(id, r, v): print("EventBus.set_exchange_rate | id: %s | resource: %s | value: %s" % [id, Model.ResourceTypes.keys()[r], v]))
	EventBus.request_set_pirate.connect(func(id: int, hex: Axial): print("EventBus.request_set_pirate | id: %s | hex: %s" % [id, hex]))
	EventBus.request_steal_from.connect(func(id: int): print("EventBus.request_steal_from | id: %d" % id))
	EventBus.discard_resources.connect(func(id: int, discard: Wallet): print("EventBus.discard_resources | id: %s | discard: %s" % [id, discard]))
	EventBus.play_monopoly_card.connect(func(id: int, resource: Model.ResourceTypes): print("EventBus.play_monopoly_card | id: %s | resource: %s" % [id, Model.ResourceTypes.find_key(resource)]))

	# Service to Model
	EventBus.set_house.connect(func(source_id: int, corner: Axial): print("EventBus.set_house | source_id: %s | corner: %s" % [source_id, corner]))
	EventBus.set_city.connect(func(source_id: int, corner: Axial): print("EventBus.set_city | source_id: %s | corner: %s" % [source_id, corner]))
	EventBus.set_road.connect(func(source_id: int, edge: AxialEdge): print("EventBus.set_road | source_id: %s | edge: %s" % [source_id, edge]))

	# Debug
	EventBus.set_player_view.connect(func(id: int): print("EventBus.set_player_view | id: %s" % id))
	EventBus.specify_roll.connect(func(d1: int, d2: int): print("EventBus.specify_roll | d1: %s | d2: %s" % [d1, d2]))	
	EventBus.service_error.connect(func(id: int, msg: String): print("EventBus.service_error | id: %s | msg: %s" % [id, msg]))
	