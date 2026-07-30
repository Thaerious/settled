extends PanelContainer


func _ready() -> void:
	EventBus.current_phase_updated.connect(self._hnd_current_phase_updated)
	EventBus.model_loaded.connect(self._on_model_loaded)


func _hnd_current_phase_updated(phase: Model.GamePhase) -> void:
	if phase == Model.GamePhase.PRE_ROLL:
		%ButtonAccept.text = "Roll"
		%ButtonAccept.disabled = false
	elif phase == Model.GamePhase.MAIN:
		%ButtonAccept.text = "End Turn"
		%ButtonAccept.disabled = false
	else:
		%ButtonAccept.text = "End Turn"
		%ButtonAccept.disabled = true


func _on_model_loaded() -> void:
	self._hnd_current_phase_updated(Game.model.get_current_phase())	
