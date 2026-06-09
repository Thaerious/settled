class_name PlayAsButton
extends Button

@export var id: int = -1


func _ready() -> void:
	print("PlayAsButon ready | %s" % self.id)
	EventBus.model_loaded.connect(self._view_set)


func _pressed():
	print("PlayAsButon._pressed | Game.self_id %s | self.id %s" % [Game.self_id, self.id])
	%AutoUpdate.button_pressed = false 
	EventBus.set_player_view.emit(self.id)


func _view_set():
	print("PlayAsButon.view_set | Game.self_id %s | self.id %s" % [Game.self_id, self.id])
	if Game.self_id == self.id:
		self.modulate = Color.RED
	else:
		self.modulate = Color.WHITE