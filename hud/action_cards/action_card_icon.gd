class_name ActionCardIcon
extends TextureRect

@export var action_card := Model.ActionCardTypes.BUILD_ROAD


func _gui_input(event) -> void:
	if not Game.model.get_current_player() == Game.self_id: return
	if not Game.model.get_current_phase() == Model.GamePhase.MAIN: return
	if not event is InputEventMouseButton: return

	print("Action Card GUI Input")

	var mouse_event = event as InputEventMouseButton
	if mouse_event.button_index != MouseButton.MOUSE_BUTTON_LEFT: return
	if not mouse_event.pressed: return
	
	if mouse_event.ctrl_pressed:
		EventBus.add_action_card.emit(Game.self_id, action_card)
	else:
		EventBus.request_play_action_card.emit(Game.self_id, action_card)
	