class_name ActionCardIcon
extends TextureRect

@export var action_card := Model.ActionCardTypes.BUILD_ROAD
@export var enabled := false

func _ready() -> void:
	EventBus.action_cards_updated.connect(self._action_cards_updated)
	EventBus.model_loaded.connect(self._model_loaded)


func _model_loaded(): 
	self._action_cards_updated(
		Game.self_id, 
		Game.model.get_owned_action_cards(Game.self_id),
		Game.model.get_playable_action_cards(Game.self_id)
	)


func _action_cards_updated(id: int, _owned: ActionCardWallet, playable: ActionCardWallet) -> void:
	if not id == Game.self_id: return
	if playable.has_card(self.action_card):
		self.modulate = Color.WHITE
		self.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		self.enabled = true
	else:
		self.modulate = Color.GRAY
		self.mouse_default_cursor_shape = Control.CURSOR_ARROW
		self.enabled = false


func _gui_input(event) -> void:	
	if not Game.model.get_current_player() == Game.self_id: return
	if not Game.model.get_current_phase() == Model.GamePhase.MAIN: return
	if not event is InputEventMouseButton: return
	var mouse_event = event as InputEventMouseButton	
	if mouse_event.button_index != MouseButton.MOUSE_BUTTON_LEFT: return
	if not mouse_event.pressed: return	

	if mouse_event.ctrl_pressed:
		EventBus.request_add_action_card.emit(Game.self_id, action_card)
	elif self.enabled:
		EventBus.request_play_action_card.emit(Game.self_id, action_card)




	

	
