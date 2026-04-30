# event_bus.gd
@warning_ignore_start("unused_signal")
extends Node

# View to view events
signal show_house_targets()
signal show_initial_house_targets()
signal show_initial_road_targets(house_axial: Axial)
signal show_city_targets()
signal show_road_targets()
signal clear_targets()

# View to service events
signal request_roll()
signal request_purchase_action_card()
signal request_play_action_card(id: int, card: Model.ActionCards)
signal request_initial_house(id: int, hex: Axial)
signal request_initial_road(id: int, edge: AxialEdge)
signal request_house(source_id: int, corner: Axial)
signal request_city(source_id: int, corner: Axial)
signal request_road(source_id: int, edge: AxialEdge)

# Model/Service to view events
signal set_dice(d1: int, d2:int)
signal add_resources(id: int, resources: Array[Model.ResourceTypes])
signal remove_resources(id: int, resources: Array[Model.ResourceTypes])
signal add_action_card(id: int, card: Model.ActionCards)
signal update_victory_points(id: int, delta: int)
signal update_longest_road(id: int)
signal update_largest_army(id: int)
signal update_player_phase(current_player: int, phase: Model.GamePhase)
signal reset_view()

# Service to Model/View events
signal set_house(source_id: int, corner: Axial)
signal set_city(source_id: int, corner: Axial)
signal set_road(source_id: int, edge: AxialEdge)


# Debug and development signals
signal set_player_view(id: int)
