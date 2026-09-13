## hand_dialog.gd
class_name HandDialog
extends PanelContainer


func _ready() -> void:
	EventBus.current_player_updated.connect(self._on_current_player_updated)


func _unhandled_key_input(event: InputEvent):
	print(event)
	if event is InputEventKey and event.keycode == KEY_ALT:
		print("GUI EVENT HAND DIALOG")
		if event.pressed: 
			self._display_bank()
		else:
			self._display_hand()


func _display_bank() -> void:
	var action_cards = Game.model.get_remaining_action_cards()
	print(action_cards)
	var resources = Game.model.get_remaining_resources()

	for child:HandActionControl in %ActionContainter.get_children():
		child.quantity = str(action_cards.get_card(child.action_type))

	for child in %ResourceContainer.get_children():
		child.quantity = str(resources.get_resource(child.resource_type))


func _display_hand() -> void:
	for child:HandActionControl in %ActionContainter.get_children():
		child.reset_view()

	for child:HandResourceControl in %ResourceContainer.get_children():
		child.reset_view()


func _on_current_player_updated(id: int) -> void:
	var do_enable = id == Game.self_id
	for child in %ResourceContainer.get_children():
		child.hoverable = do_enable
		child.drag_node.disabled = !do_enable
