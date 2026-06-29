class_name DragNode
extends Node

signal drag_start()
signal drag_end(rec: DragRecord)

var _dragging := false
var _sprite: Sprite2D = null

@export var enabled = true
@export_flags_2d_physics var drag_mask: int = 1

# connect a press handler to trigger that is invoked on a LMB press
func _ready() -> void:
	self._set_child_mouse_filters()
	self.get_parent().gui_input.connect(self._on_press)
	self._sprite = get_child(0)


func _set_child_mouse_filters() -> void:
	for child in get_parent().find_children("*", "", true, false):
		if child == self: continue
		if not child is Control: continue
		child.mouse_filter = Control.MOUSE_FILTER_PASS
			

## Moves the drag ghost to follow the cursor and updates the hover target each frame.
func _process(_delta: float) -> void:
	if not self._dragging: return
	self._sprite.global_position = get_viewport().get_mouse_position()	


func _on_press(event: InputEvent) -> void:
	if not self.enabled: return
	elif event is InputEventMouseMotion: self._on_mouse_motion(event)	
	elif event is InputEventMouse: self._on_mouse_input(event)		


func _on_mouse_input(event: InputEventMouse) -> void:
	if is_left_press(event): 
		if not self._dragging: self._do_start_drag()

	if is_left_release(event):		
		if self._dragging: self._do_stop_drag()


func _on_mouse_motion(_event: InputEventMouseMotion) -> void:
	self.get_parent().mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


func _do_start_drag() -> void:
	self._dragging = true
	self._sprite.visible = true
	self._sprite.top_level = true
	self.on_drag_start()
	self.drag_start.emit()


## Ends the active drag, resolves the drop target, and invokes the appropriate callback.
func _do_stop_drag() -> void:
	self._dragging = false
	self._sprite.visible = false
	self._sprite.top_level = false
	var rec := MouseHelper.resolve_target(self.drag_mask)
	rec.draggable = self
	self.on_drag_end(rec)
	self.drag_end.emit(rec)


func on_drag_start() -> void:
	pass


func on_drag_end(_rec: DragRecord) -> void:
	pass


# func _on_enter(_rec: HoverRecord) -> void:
# 	pass


# func _on_exit(_rec: HoverRecord) -> void:
# 	pass


static func is_left_press(event: InputEvent) -> bool:
	return (
		event is InputEventMouseButton
		and event.button_index == MouseButton.MOUSE_BUTTON_LEFT
		and event.pressed
	)	

static func is_left_release(event: InputEvent) -> bool:
	return (
		event is InputEventMouseButton
		and event.button_index == MouseButton.MOUSE_BUTTON_LEFT
		and not event.pressed
	)		
