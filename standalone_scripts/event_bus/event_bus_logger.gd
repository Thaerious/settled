## event_bus_logger.gd
class_name EventBusLogger
extends Node

func _ready() -> void:
	EventBus.show_house_targets.connect(func(): print("EventBus.show_house_targets"))
	EventBus.show_city_targets.connect(func(): print("EventBus.show_city_targets"))
	EventBus.show_road_targets.connect(func(): print("EventBus.show_road_targets"))
	EventBus.clear_targets.connect(func(): print("EventBus.clear_targets"))
	EventBus.set_dice.connect(func(d1: int, d2: int): print("EventBus.set_dice | d1: %s | d2: %s" % [d1, d2]))
	EventBus.set_house.connect(func(id: int, corner: Axial): print("EventBus.set_house | id: %s | corner: %s" % [id, corner]))
	EventBus.set_city.connect(func(id: int, corner: Axial): print("EventBus.set_city | id: %s | corner: %s" % [id, corner]))
	EventBus.set_road.connect(func(id: int, edge: AxialEdge): print("EventBus.set_road | id: %s | edge: %s" % [id, edge]))
	EventBus.request_roll.connect(func(): print("EventBus.request_roll"))
	EventBus.add_resources.connect(func(id: int, resources: Array[Model.ResourceTypes]): print("EventBus.add_resources | id: %s | resources: %s" % [id, resources]))
	EventBus.remove_resources.connect(func(id: int, resources: Array[Model.ResourceTypes]): print("EventBus.remove_resources | id: %s | resources: %s" % [id, resources]))
	EventBus.add_action_card.connect(func(id: int, card: Model.ActionCards): print("EventBus.purchase_action_card | id: %s | card: %s" % [id, card]))
	EventBus.add_card.connect(func(id: int, card: Model.ActionCards): print("EventBus.add_card | id: %s | card: %s" % [id, card]))

