class_name HandPanelContainer
extends PanelContainer


func _ready():
	EventBus.update_phase.connect(self._update)

	EventBus.reset_view.connect(func():
		self._update(Game.model.get_current_phase())
	)


func _update(phase: Model.GamePhase) -> void:
	match phase:
		Model.GamePhase.DISCARD:self.visible = false
		Model.GamePhase.MONOPOLY: self.visible = false
		Model.GamePhase.YEAR_OF_PLENTY: self.visible = false
		_: self.visible = true	