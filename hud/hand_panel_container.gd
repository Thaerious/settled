class_name HandPanelContainer
extends PanelContainer


func _ready():
	EventBus.current_phase_updated.connect(self._update)

	EventBus.model_loaded.connect(func():
		self._update(Game.model.get_current_phase())
	)


func _update(phase: Model.GamePhase) -> void:
	match phase:
		Model.GamePhase.DURING_DISCARD: self.visible = false
		Model.GamePhase.MONOPOLY: self.visible = false
		Model.GamePhase.YEAR_OF_PLENTY: self.visible = false
		_: self.visible = true	