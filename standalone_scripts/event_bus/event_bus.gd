@warning_ignore_start("unused_signal")
extends Node

# view signals
signal show_house_targets()
signal show_city_targets()
signal show_road_targets()
signal clear_targets()

# set model signals
signal set_house(source_id: int, corner: Axial)
signal set_city(source_id: int, corner: Axial)
signal set_road(source_id: int, edge: AxialEdge)
signal set_roll(d1: int, d2: int)