## event_bus_logger.gd
class_name EventBusLogger
extends Node


func _ready() -> void:
	# View to view
	EventBus.show_house_targets.connect(func(): print("EventBus.show_house_targets"))
	EventBus.show_city_targets.connect(func(): print("EventBus.show_city_targets"))
	EventBus.show_road_targets.connect(func(): print("EventBus.show_road_targets"))
	EventBus.clear_targets.connect(func(): print("EventBus.clear_targets"))

	# View to model
	EventBus.request_roll.connect(func(): print("EventBus.request_roll"))
	EventBus.request_purchase_action_card.connect(func(): print("EventBus.request_purchase_action_card"))
	EventBus.play_action_card.connect(func(id: int, card: Model.ActionCards): print("EventBus.play_action_card | id: %s | card: %s" % [id, card]))

	# Model to view
	EventBus.set_dice.connect(func(d1: int, d2: int): print("EventBus.set_dice | d1: %s | d2: %s" % [d1, d2]))
	EventBus.set_house.connect(func(id: int, corner: Axial): print("EventBus.set_house | id: %s | corner: %s" % [id, corner]))
	EventBus.set_city.connect(func(id: int, corner: Axial): print("EventBus.set_city | id: %s | corner: %s" % [id, corner]))
	EventBus.set_road.connect(func(id: int, edge: AxialEdge): print("EventBus.set_road | id: %s | edge: %s" % [id, edge]))
	EventBus.add_resources.connect(func(id: int, resources: Array[Model.ResourceTypes]): print("EventBus.add_resources | id: %s | resources: %s" % [id, resources]))
	EventBus.remove_resources.connect(func(id: int, resources: Array[Model.ResourceTypes]): print("EventBus.remove_resources | id: %s | resources: %s" % [id, resources]))
	EventBus.add_action_card.connect(func(id: int, card: Model.ActionCards): print("EventBus.add_action_card | id: %s | card: %s" % [id, card]))
	EventBus.update_victory_points.connect(func(id: int, delta: int): print("EventBus.update_victory_points | id: %s | delta: %s" % [id, delta]))
	EventBus.update_longest_road.connect(func(id: int): print("EventBus.update_longest_road | id: %s" % id))
	EventBus.update_largest_army.connect(func(id: int): print("EventBus.update_largest_army | id: %s" % id))
	EventBus.update_player_phase.connect(func(id: int, phase): print("EventBus.update_current_player | id: %s | phase: %s" % [id, phase]))
	EventBus.reset_view.connect(func(): print("EventBus.reset_view"))

	# Debug
	EventBus.set_player_view.connect(func(id: int): print("EventBus.set_player_view | id: %s" % id))
	