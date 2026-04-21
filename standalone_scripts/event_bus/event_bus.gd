@warning_ignore_start("unused_signal")
extends Node

signal show_house_targets()
signal show_city_targets()
signal show_road_targets()
signal clear_targets()
signal set_house(source_id: int, corner: Axial)
signal set_city(source_id: int, corner: Axial)
signal set_road(source_id: int, edge: AxialEdge)