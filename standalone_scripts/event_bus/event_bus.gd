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
signal request_house(id: int, corner: Axial)
signal request_city(id: int, corner: Axial)
signal request_road(id: int, edge: AxialEdge)
signal requst_exchange(id: int, from: Model.ResourceTypes, to: Model.ResourceTypes)
signal request_set_pirate(id: int, hex: Axial)

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
signal set_house(id: int, corner: Axial)
signal set_city(id: int, corner: Axial)
signal set_road(id: int, edge: AxialEdge)
signal set_exchange_rate(id: int, r: Model.ResourceTypes, value: int)
signal set_pirate(hex: Axial)

# Debug and development signals
signal set_player_view(id: int)
