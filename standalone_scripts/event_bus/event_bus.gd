@warning_ignore_start("unused_signal")
extends Node

# view signals
signal show_house_targets()
signal show_city_targets()
signal show_road_targets()
signal clear_targets()
signal set_dice(d1: int, d2:int)


# signals that trigger a change on the model
signal set_house(source_id: int, corner: Axial)
signal set_city(source_id: int, corner: Axial)
signal set_road(source_id: int, edge: AxialEdge)

signal request_roll()
signal add_resources(id: int, resources: Array[Model.ResourceTypes])
signal remove_resources(id: int, resources: Array[Model.ResourceTypes])
