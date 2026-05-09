class_name PlentyDeialog
extends Control

var _button_group1: ButtonGroup
var _button_group2: ButtonGroup
	

func _ready() -> void:
	self._button_group1 = %CheckBrick1.button_group
	self._button_group2 = %CheckBrick2.button_group

	%OkButton.pressed.connect(self._on_accept)

	EventBus.phase_updated.connect(self._update_phase)
	EventBus.model_loaded.connect(func(): 
		self._update_phase(Game.model.get_current_phase())
	)


func _update_phase(phase: Model.GamePhase) -> void:
	self.visible = false	

	if phase != Model.GamePhase.YEAR_OF_PLENTY: return
	if not Game.model.get_current_player() == Game.self_id: return

	self.visible = true	


func _on_accept() -> void:
	var button1 = self._button_group1.get_pressed_button()
	var button2 = self._button_group2.get_pressed_button()
	var wallet = Wallet.new([button1.resource, button2.resource])
	EventBus.play_plenty_card.emit(Game.self_id, wallet)	
