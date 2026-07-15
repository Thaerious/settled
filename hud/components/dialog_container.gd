class_name DialogContainer
extends PanelContainer


func _ready() -> void:
	EventBus.current_phase_updated.connect(self._on_current_phase_updated)
	EventBus.model_loaded.connect(self._on_model_loaded)


func _on_current_phase_updated(phase: Model.GamePhase) -> void:
	match phase:
		Model.GamePhase.NOT_STARTED: 
			self.visible = false
		_: self.visible = false	


func _on_model_loaded() -> void:
	self._on_current_phase_updated(Game.model.get_current_phase())		
