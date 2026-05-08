class_name PlayerButton
extends Button

@export var id: int = -1


func _ready() -> void:
	EventBus.update_player.connect(self._update)
	EventBus.reset_view.connect(self._reset)


func _pressed():
	EventBus.update_player.emit(self.id)


func _update(id: int):
	if id == self.id:
		self.modulate = Color.RED
	else:
		self.modulate = Color.WHITE


func _reset():
	if Game.model.get_current_player() == self.id:
		self.modulate = Color.RED
	else:
		self.modulate = Color.WHITE