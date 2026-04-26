# event_bus.gd
@warning_ignore_start("unused_signal")
extends Node


signal show_house_targets()
signal show_city_targets()
signal show_road_targets()
signal clear_targets()
signal set_dice(d1: int, d2:int)
signal request_roll()
signal request_purchase_action_card()

signal set_house(source_id: int, corner: Axial)
signal set_city(source_id: int, corner: Axial)
signal set_road(source_id: int, edge: AxialEdge)
signal add_card(id: int, card: Model.ActionCards)


signal add_resources(id: int, resources: Array[Model.ResourceTypes])
signal remove_resources(id: int, resources: Array[Model.ResourceTypes])
signal add_action_card(id: int, card: Model.ActionCards)
