# filename: phase_buttons/button_end.gd
extends Button


func _pressed():
	EventBus.request_end_turn.emit()
