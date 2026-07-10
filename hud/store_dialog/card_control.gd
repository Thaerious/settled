@tool
class_name CardControl
extends DialogControl

func _ready() -> void:
	super._ready()
	self.gui_input.connect(self._on_press)


func _on_press(event: InputEvent) -> void:
	if self.disabled: return
	if not event is InputEventMouseButton: return
	if not MouseHelper.is_left_release(event): return
	if not get_viewport().gui_get_hovered_control(): return
	if not get_viewport().gui_get_hovered_control().owner == self: return

	EventBus.request_purchase_action_card.emit()