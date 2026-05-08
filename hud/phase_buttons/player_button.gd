class_name PlayerButton
extends Button

@export var id: int = -1


func _ready() -> void:
	EventBus.update_player_phase.connect(self._update)
	EventBus.reset_view.connect(self._reset)


func _pressed():
	EventBus.update_player_phase.emit(self.id, Game.model.get_current_phase())


func _update(id: int, _phase: Model.GamePhase):
	if id == self.id:
		self.modulate = Color.RED
	else:
		self.modulate = Color.WHITE


func _reset():
	if Game.model.get_current_player() == self.id:
		self.modulate = Color.RED
	else:
		self.modulate = Color.WHITE