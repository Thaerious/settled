## event_bus_logger.gd
class_name EventBusLogger
extends Node

func _ready() -> void:
    EventBus.show_house_targets.connect(func(): print("EventBus.show_house_targets"))
    EventBus.show_city_targets.connect(func(): print("EventBus.show_city_targets"))
    EventBus.show_road_targets.connect(func(): print("EventBus.show_road_targets"))
    EventBus.clear_targets.connect(func(): print("EventBus.clear_targets"))
    EventBus.set_house.connect(func(id:int, position: Vector2): print("EventBus.set_house | id: %s | position: %s " % [id, position]))
