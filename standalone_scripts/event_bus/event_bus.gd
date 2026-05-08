# event_bus.gd
@warning_ignore_start("unused_signal")
extends Node

# View to view events (show, clear)
signal show_house_targets()
signal show_initial_house_targets()
signal show_initial_road_targets(house_axial: Axial)
signal show_city_targets()
signal show_road_targets()
signal clear_targets()

# View to service events (request, play)
signal request_roll()
signal request_purchase_action_card()
signal request_play_action_card(id: int, card: Model.ActionCardTypes)
signal request_initial_house(id: int, hex: Axial)
signal request_initial_road(id: int, edge: AxialEdge)
signal request_house(id: int, corner: Axial)
signal request_city(id: int, corner: Axial)
signal request_road(id: int, edge: AxialEdge)
signal request_exchange(id: int, from: Model.ResourceTypes, to: Model.ResourceTypes)
signal request_set_pirate(id: int, hex: Axial)
signal request_steal_from(id: int)

signal play_monopoly_card(id: int, resource: Model.ResourceTypes)
signal play_plenty_card(id: int, resources: Wallet)
signal play_victory_card(id: int)
signal play_soldier_card(id: int)
signal play_road_building_card(id: int)

signal discard_resources(id:int, discard: Wallet)
signal update_player_phase(current_player: int, phase: Model.GamePhase)

# Model/Service to view events
signal set_dice(d1: int, d2:int)
signal add_resources(id: int, wallet: Wallet)
signal remove_resources(id: int, wallet: Wallet)
signal update_action_card(id: int, cards: ActionCardsContainer)
signal update_victory_points(id: int, delta: int)
signal update_longest_road(id: int)
signal update_largest_army(id: int)
signal reset_view()

# Service to Model/View events (add, remove, set)
signal set_house(id: int, corner: Axial)
signal set_city(id: int, corner: Axial)
signal set_road(id: int, edge: AxialEdge)
signal set_exchange_rate(id: int, r: Model.ResourceTypes, value: int)
signal set_pirate(hex: Axial)
signal add_victory_point(id: int)
signal add_soldier(id: int)

signal add_action_card(id: int, c: Model.ActionCardTypes)
signal remove_action_card(id: int, c: Model.ActionCardTypes)
signal set_action_cards(id: int, ac_wallet: ActionCardWallet)

# Debug and development signals
signal set_player_view(id: int)
signal save_model_state()
signal load_model_state()
signal specify_roll(d1: int, d2: int)

# Terminal Events
signal service_error(id: int, msg: String)