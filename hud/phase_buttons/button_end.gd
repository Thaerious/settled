extends Button


func _pressed():
	EventBus.request_end_turn.emit()
