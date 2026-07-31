## hand_dialog.gd
class_name HandDialog
extends PanelContainer


func _ready() -> void:
	EventBus.current_player_updated.connect(self._on_current_player_updated)


func _on_current_player_updated(id: int) -> void:
	var do_enable = id == Game.self_id
	for child in %ResourceContainer.get_children():
		child.hoverable = do_enable
		child.drag_node.disabled = !do_enable

