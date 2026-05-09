class_name MonopolyDialog
extends Control

var _button_group: ButtonGroup
	

func _ready() -> void:
	self._button_group = %CheckBrick.button_group

	%OkButton.pressed.connect(self._on_accept)

	EventBus.phase_updated.connect(self._update_phase)
	EventBus.model_loaded.connect(func(): 
		self._update_phase(Game.model.get_current_phase())
	)


func _update_phase(phase: Model.GamePhase) -> void:
	self.visible = false	

	if phase != Model.GamePhase.MONOPOLY: return
	if not Game.model.get_current_player() == Game.self_id: return

	self.visible = true	


func _on_accept() -> void:
	var button = self._button_group.get_pressed_button()
	EventBus.play_monopoly_card.emit(Game.self_id, button.resource)	
