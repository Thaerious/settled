class_name DialogContainer
extends PanelContainer

@export var visible_phase: Model.GamePhase = Model.GamePhase.ALL
@export var hide_when_not_my_turn := false


func _ready() -> void:
	EventBus.current_phase_updated.connect(self._hnd_visible_phase)


func _hnd_visible_phase(phase: Model.GamePhase) -> void:
	if Game.model.get_current_player() != Game.self_id and self.hide_when_not_my_turn: 
		self.visible = false
	elif visible_phase == Model.GamePhase.ALL:
		self.visible = true
	elif visible_phase == Model.GamePhase.NONE:
		pass
	elif phase == self.visible_phase: 
		self.visible = true
	else: 
		self.visible = false

	if self.visible:
		self.move_to_front()
