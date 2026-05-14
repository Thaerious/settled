class_name PhaseButton
extends Button

@export var phase: Model.GamePhase = Model.GamePhase.NOT_STARTED


func _ready() -> void:
	EventBus.current_phase_updated.connect(self._update)
	EventBus.model_loaded.connect(self._reset)


func _pressed():
	Game.model.do_update_phase(self.phase)


func _update(phase: Model.GamePhase):
	if phase == self.phase:
		self.modulate = Color.RED
	else:
		self.modulate = Color.WHITE


func _reset():
	if Game.model.get_current_phase() == self.phase:
		self.modulate = Color.RED
	else:
		self.modulate = Color.WHITE