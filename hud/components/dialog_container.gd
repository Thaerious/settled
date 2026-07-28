class_name DialogContainer
extends PanelContainer


@export var visible_phase: Model.GamePhase = Model.GamePhase.ALL
@export var hide_when_not_my_turn := false

func _ready() -> void:
	EventBus.current_phase_updated.connect(self._hnd_current_phase_updated)
	EventBus.model_loaded.connect(self._on_model_loaded)


func _hnd_current_phase_updated(phase: Model.GamePhase) -> void:
	if Game.model.get_current_player() != Game.self_id and self.hide_when_not_my_turn: 
		self.visible = false
	elif visible_phase == Model.GamePhase.ALL:
		self.visible = true
	elif visible_phase == Model.GamePhase.NONE:
		self.visible = false
	elif phase == self.visible_phase: 
		self.visible = true
	else: 
		self.visible = false


func _on_model_loaded() -> void:
	self._hnd_current_phase_updated(Game.model.get_current_phase())		
