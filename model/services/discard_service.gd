class_name DiscardService
extends Node

func _init() -> void:
	EventBus.phase_updated.connect(self._update_phase_hnd)
	EventBus.discard_resources.connect(self._discard_resources_hnd)
	EventBus.model_loaded.connect(func(): self._update_phase_hnd(Game.model.get_current_phase()))


func count_discarded() -> int:
	var discarded := Game.model.get_discarded()
	print(discarded)
	var count = 0
	for i in Game.player_count: if not discarded[i]: count += 1
	return count


func _update_phase_hnd(phase: Model.GamePhase) -> void:
	if phase != Model.GamePhase.INIT_DISCARD: return

	for id in Game.player_count: 
		var bank := Game.model.get_bank(id)
		if bank.count_resources() <= 7:
			Game.model.set_discard(id, false)
		else:
			Game.model.set_discard(id, true)

	if self.count_discarded() == Game.player_count:
		Game.model.do_update_phase.bind(Model.GamePhase.MOVE_PIRATE).call_deferred()
	else:
		Game.model.do_update_phase.bind(Model.GamePhase.DURING_DISCARD).call_deferred()


func _discard_resources_hnd(id:int, discard: Wallet) -> void:
	var bank := Game.model.get_bank(id)
	var must_discard:int = ceili((bank.count_resources() - 7.0) / 2.0)

	if discard.count_resources() != must_discard:
		EventBus.service_error.emit(id, "Discard resources mis-alligned.")
		return

	Game.model.do_discard(id, discard)

	if self.count_discarded() == Game.player_count:
		Game.model.do_update_phase.bind(Model.GamePhase.MOVE_PIRATE).call_deferred()
