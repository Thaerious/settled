class_name HandPanelContainer
extends PanelContainer


func _ready():
	EventBus.update_player_phase.connect(self._update)

	EventBus.reset_view.connect(func():
		self._update(Game.self_id, Game.model.get_current_phase())
	)


func _update(_id: int, phase: Model.GamePhase) -> void:
	match phase:
		Model.GamePhase.DISCARD:
			self.visible = false
		_:
			self.visible = true	