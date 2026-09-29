# filename: event_bus/event_bus.gd
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
signal request_purchase_action_card(pid: int)
signal request_play_action_card(pid: int, card: Model.ActionCardTypes)
signal request_house(pid: int, corner: Axial)
signal request_city(pid: int, corner: Axial)
signal request_road(pid: int, edge: AxialEdge)
signal request_exchange(pid: int, from: Model.ResourceTypes, to: Model.ResourceTypes)
signal request_set_pirate(pid: int, hex: Axial)
signal request_steal_from(pid:int, victim: int)
signal request_discard(pid:int, discard: Wallet)
signal request_end_turn()
signal monopoly_card_decision(pid: int, resource: Model.ResourceTypes)
signal plenty_card_decision(pid: int, resources: Wallet)

# Model outgoing events (only the model or service should emit these)
signal model_loaded()
signal pirate_set(hex: Axial)
signal exchange_rate_set(pid: int, wallet: Wallet)
signal current_player_updated(current_player: int)
signal current_phase_updated(phase: Model.GamePhase)
signal action_cards_updated(pid: int, owned: ActionCardWallet, playable: ActionCardWallet)
signal house_added(pid: int, corner: Axial)
signal city_added(pid: int, corner: Axial)
signal road_added(pid: int, edge: AxialEdge)
signal dice_set(d1: int, d2:int)
signal player_record_updated(record: PlayerRecord)
signal resources_updated(pid: int, wallet:Wallet)
signal resources_received(pid: int, wallet:Wallet)
signal end_game(vp: Dictionary[int, int]) # vp is hidden victory points

# Debug and Development Events
signal set_player_view(pid: int)

# Notification Events
signal notify(pid: int, msg: String) # for popup boxes
signal info(pid: int, msg: String) # for infofox messages
signal error(msg: String) # for infofox messages
signal end_turn(pid: int) # emitted between turns, id is the next player


func send_info(pid: int, msg1: String, msg2: String) -> void:
	if pid == -1: 
		EventBus.info.emit(-1, msg1)
		return
	
	for player in Game.model.player_count():
		if player == pid:
			EventBus.info.emit(player, msg1)
		else:
			EventBus.info.emit(player, msg2)
