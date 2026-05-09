class_name DiscardService
extends Node

var _has_discarded: int = 0
var _discards: Dictionary[int, Wallet] = {}


func _init() -> void:
	EventBus.phase_updated.connect(self._update_phase_hnd)
	EventBus.discard_resources.connect(self._discard_resources_hnd)
	EventBus.model_loaded.connect(func(): self._update_phase_hnd(Game.model.get_current_phase()))


func _update_phase_hnd(phase: Model.GamePhase) -> void:
	if phase != Model.GamePhase.DISCARD: return

	for i in Game.player_count:
		var bank := Game.model.get_bank(i)
		if bank.count_resources() <= 7:
			self._has_discarded += 1

	if self._has_discarded == Game.player_count:
		self._has_discarded = 0
		Game.model.do_update_phase.bind(Model.GamePhase.MOVE_PIRATE).call_deferred()

func _discard_resources_hnd(id:int, discard: Wallet) -> void:
	var bank := Game.model.get_bank(id)
	var must_discard:int = ceili((bank.count_resources() - 7.0) / 2.0)

	if discard.count_resources() != must_discard:
		EventBus.service_error.emit(id, "Discard resources mis-alligned.")
		return

	self._has_discarded += 1
	self._discards[id] = discard
	
	if self._has_discarded == Game.player_count:
		self._has_discarded = 0
		for key in self._discards.keys():
			EventBus.remove_resources.emit(key, self._discards[key])
			
		Game.model.do_update_phase(Model.GamePhase.MOVE_PIRATE)
