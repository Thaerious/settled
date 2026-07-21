extends Node2D


func _on_button_button_up():
	EventBus.current_phase_updated.emit(Model.GamePhase.SETUP)
