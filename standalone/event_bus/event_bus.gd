# event_bus.gd
@warning_ignore_start("unused_signal")
extends Node

# View to view events (show, clear)
# Does not require id since only the client needs view events.
signal show_house_targets()
signal show_city_targets()
signal show_road_targets()
signal clear_targets()

# View to service events (request, play)
signal request_roll()
signal request_purchase_action_card(id: int)
signal request_play_action_card(id: int, card: Model.ActionCardTypes)
signal request_house(id: int, corner: Axial)
signal request_city(id: int, corner: Axial)
signal request_road(id: int, edge: AxialEdge)
signal request_exchange(id: int, from: Model.ResourceTypes, to: Model.ResourceTypes)
signal request_set_pirate(id: int, hex: Axial)
signal request_steal_from(id: int)
signal request_add_action_card(id: int, c: Model.ActionCardTypes)
signal request_discard(id:int, discard: Wallet)
signal request_end_turn()
signal play_monopoly_card(id: int, resource: Model.ResourceTypes)
signal play_plenty_card(id: int, resources: Wallet)
signal play_road_building_card(id: int, roads: AxialEdgeSet) 

# Model outgoing events (only the model or service should emit these)
signal model_loaded()
signal pirate_set(hex: Axial)
signal exchange_rate_set(id: int, wallet: Wallet)
signal current_player_updated(current_player: int)
signal current_phase_updated(phase: Model.GamePhase)
signal action_cards_updated(id: int, owned: ActionCardWallet, playable: ActionCardWallet)
signal house_added(id: int, corner: Axial)
signal city_added(id: int, corner: Axial)
signal road_added(id: int, edge: AxialEdge)
signal dice_set(d1: int, d2:int)
signal player_record_updated(record: PlayerRecord)
signal resources_updated(id: int, wallet:Wallet)
signal resources_received(id: int, wallet:Wallet)

# Debug and Development Events
signal set_player_view(id: int)

# Notification Events
signal notify(id: int, msg: String) # for popup boxes
signal info(id: int, msg: String) # for infofox messages
signal error(msg: String) # for infofox messages
