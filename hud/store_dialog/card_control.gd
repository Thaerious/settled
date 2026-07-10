@tool
class_name CardControl
extends DialogControl

func _ready() -> void:
	super._ready()
	self.gui_input.connect(self._on_press)


func _on_press(event: InputEvent) -> void:
	if self.disabled: return
	if not event is InputEventMouseButton: return
	
	if is_left_press(event): 
		if not self._dragging: self._do_start_drag()

	if is_left_release(event):		
		if self._dragging: self._do_stop_drag()

	EventBus.request_purchase_action_card.emit()