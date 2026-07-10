class_name DragNode
extends Node

signal drag_start()
signal drag_end(rec: DragRecord)
signal hover_enter(rec: DragRecord)
signal hover_exit(rec: DragRecord)

## The node currently under the cursor during a drag.
## [code]null[/code] when nothing is hovered.
var _last_hover_target: Node = null

## True when actively dragging
var _dragging := false

## The visual ghost node displayed under the cursor during a drag.
## This is the first child attached to the drag node.
var _sprite: Sprite2D = null

@export var disabled = false
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
	self._update_hover()


func _update_hover() -> void:
	var record := MouseHelper.resolve_drag_target(self.drag_mask)
	
	if record.destination == self._last_hover_target: 
		return

	if self._last_hover_target: 
		self.hover_exit.emit(record)

	if record.destination: 
		self.hover_enter.emit(record)

	self._last_hover_target = record.destination


func _on_press(event: InputEvent) -> void:
	if self.disabled: return
	elif event is InputEventMouseMotion: self._on_mouse_motion(event)	
	elif event is InputEventMouse: self._on_mouse_input(event)		


func _on_mouse_input(event: InputEventMouse) -> void:
	if MouseHelper.is_left_press(event): 
		if not self._dragging: self._do_start_drag()

	if MouseHelper.is_left_release(event):		
		if self._dragging: self._do_stop_drag()


func _on_mouse_motion(_event: InputEventMouseMotion) -> void:
	self.get_parent().mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


func _do_start_drag() -> void:
	self._dragging = true
	self._sprite.visible = true
	self._sprite.top_level = true
	self.drag_start.emit()


## Ends the active drag, resolves the drop target, and invokes the appropriate callback.
func _do_stop_drag() -> void:
	self._dragging = false
	self._sprite.visible = false
	self._sprite.top_level = false
	var rec := MouseHelper.resolve_drag_target(self.drag_mask)
	self.drag_end.emit(rec)


