class_name WaitingDialog
extends Control


func _ready() -> void:
	EventBus.current_phase_updated.connect(self._update_phase_hnd)
	EventBus.model_loaded.connect(self._model_loaded_hnd)

func _model_loaded_hnd() -> void:
	self._update_phase_hnd(Game.model.get_current_phase())


func _update_phase_hnd(phase: Model.GamePhase) -> void:
	if phase == Model.GamePhase.DURING_DISCARD:
		self._setup_view()		
	else:
		self.visible = false		


func _setup_view() -> void:
	var target := Game.model.get_discard_target(Game.self_id)
	var count := Game.model.get_bank(Game.self_id).size()

	# true means I don't need to discard
	if target >= count:
		self.visible = true
		return		