class_name DiscardService
extends Node

func _init() -> void:
	EventBus.current_phase_updated.connect(self._update_phase_hnd)
	EventBus.request_discard.connect(self._request_discard_hnd)
	EventBus.model_loaded.connect(func(): self._update_phase_hnd(Game.model.get_current_phase()))


func count_pending() -> int:
	var count = 0

	for i in Game.player_count:
		if Game.model.get_discard_target(i) != -1:
			count += 1

	return count


func _update_phase_hnd(phase: Model.GamePhase) -> void:
	if phase != Model.GamePhase.INIT_DISCARD: return
	var next_phase = Model.GamePhase.MOVE_PIRATE

	for id in Game.player_count: 
		var bank := Game.model.get_bank(id)
		Game.model.set_discard_target(id, Model.INT_MAX)
		print("id %s | bank %s" % [id, bank.size()])
		if bank.size() < 8: continue

		next_phase = Model.GamePhase.DURING_DISCARD
		var half:int = floori(bank.size() / 2.0)
		Game.model.set_discard_target(id, half)

	Game.model.do_update_phase.bind(next_phase).call_deferred()


func _request_discard_hnd(id:int, discard: Wallet) -> void:
	var bank := Game.model.get_bank(id)
	var must_discard:int = floori(bank.size() / 2.0)

	if discard.size() != must_discard:
		EventBus.service_error.emit(id, "Discard resources mis-alligned.")
		return

	Game.model.do_discard(id, discard)

	if self.count_pending() == Game.player_count:
		Game.model.do_update_phase.bind(Model.GamePhase.MOVE_PIRATE).call_deferred()
