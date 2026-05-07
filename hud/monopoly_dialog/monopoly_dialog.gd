class_name MonopolyDialog
extends Control


var _button_group: ButtonGroup
	

func _ready() -> void:
	self._button_group = %CheckBrick.button_group

	%OkButton.pressed.connect(self._on_accept)

	EventBus.update_player_phase.connect(self._update_player_phase)
	EventBus.reset_view.connect(func(): 
		self._update_player_phase(Game.model.get_current_player(), Game.model.get_current_phase())
	)


func _update_player_phase(current_player: int, phase: Model.GamePhase) -> void:
	self.visible = false	

	if phase != Model.GamePhase.MONOPOLY: return
	if current_player != Game.self_id: return

	self.visible = true	


func _on_accept() -> void:
	var button = self._button_group.get_pressed_button()
