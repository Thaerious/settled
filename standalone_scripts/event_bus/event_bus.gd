# event_bus.gd
@warning_ignore_start("unused_signal")
extends Node

# View to view events
signal show_house_targets()
signal show_city_targets()
signal show_road_targets()
signal clear_targets()

# View to model events
signal request_roll()
signal request_purchase_action_card()
signal play_action_card(id: int, card: Model.ActionCards)

# Model to view events
signal set_dice(d1: int, d2:int)
signal set_house(source_id: int, corner: Axial)
signal set_city(source_id: int, corner: Axial)
signal set_road(source_id: int, edge: AxialEdge)
signal add_resources(id: int, resources: Array[Model.ResourceTypes])
signal remove_resources(id: int, resources: Array[Model.ResourceTypes])
signal add_action_card(id: int, card: Model.ActionCards)
signal update_victory_points(id: int, delta: int)
signal update_longest_road(id: int)
signal update_largest_army(id: int)
signal update_current_player(id: int)

# Debug and development signals
signal set_player_view(id: int)
