# event_bus.gd
@warning_ignore_start("unused_signal")
extends Node

# View to view events (show, clear)
signal show_initial_house_targets()
signal show_initial_road_targets(house_axial: Axial)
signal show_house_targets()
signal show_city_targets()
signal show_road_targets()
signal clear_targets()
signal set_road_view_only(id: int, edge: AxialEdge)

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
signal request_update_phase(phase: Model.GamePhase)
signal request_add_action_card(id: int, c: Model.ActionCardTypes)
signal request_discard(id:int, discard: Wallet)
signal request_end_turn()
signal play_monopoly_card(id: int, resource: Model.ResourceTypes)
signal play_plenty_card(id: int, resources: Wallet)
signal play_road_building_card(id: int, roads: AxialEdgeSet) 

# Model/Service to view events
signal update_longest_road(id: int)
signal update_largest_army(id: int)

# Model outgoing events (only the model should emit these)
signal model_loaded()
signal pirate_set(hex: Axial)
signal exchange_rate_set(id: int, r: Model.ResourceTypes, value: int)
signal current_player_updated(current_player: int)
signal current_phase_updated(phase: Model.GamePhase)
signal action_cards_updated(id: int, owned: ActionCardWallet, playable: ActionCardWallet)
signal house_added(id: int, corner: Axial)
signal city_added(id: int, corner: Axial)
signal road_added(id: int, edge: AxialEdge)
signal dice_set(d1: int, d2:int)
signal player_record_updated(id: int, record: PlayerRecord)
signal resources_updated(id: int, wallet:Wallet)

# Debug and development signals
signal set_player_view(id: int)
signal save_model_state()
signal load_model_state()
signal development_roll(d1: int, d2: int)

# Terminal Events
signal service_error(id: int, msg: String)

