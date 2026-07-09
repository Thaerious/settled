class_name PlayAsButton
extends Button

@export var id: int = -1


func _ready() -> void:
	EventBus.model_loaded.connect(self._view_set)


func _pressed():
	%AutoUpdate.button_pressed = false 
	EventBus.set_player_view.emit(self.id)


func _view_set():
	if Game.self_id == self.id:
		self.modulate = Color.RED
	else:
		self.modulate = Color.WHITE