# Requires an Area2D (with a CollisionShape2D child).

class_name DragNode2D
extends Area2D

signal drag_start()
signal drag_end(rec: DragRecord)
signal hover_enter(rec: DragRecord)
signal hover_exit(rec: DragRecord)

var _last_hover_target: Node = null
var _dragging := false
var _collision_shape: CollisionShape2D = null

# The node that has it's position updated, defaults to parent if null.
@export var drag_target: Node2D = null
@export var disabled = false
@export_flags_2d_physics var drag_mask: int = 1


func _ready() -> void:
	self._collision_shape = NodeHelpers.get_first_child_of_type(self, CollisionShape2D)
	self.input_event.connect(self._on_mouse_input)
	if drag_target == null: drag_target = self.get_parent()


func _process(_delta: float) -> void:
	if not self._dragging: return
	self.drag_target.global_position = get_global_mouse_position()
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


func _on_mouse_input(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if self.disabled: return
	if not event is InputEventMouseButton: return
	
	if MouseHelper.is_left_press(event):
		if not self._dragging: self._do_start_drag()

	if MouseHelper.is_left_release(event):
		if self._dragging: self._do_stop_drag()


func _do_start_drag() -> void:
	self._dragging = true
	self.drag_target.top_level = true
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	self.drag_start.emit()


func _do_stop_drag() -> void:
	self._dragging = false
	self.drag_target.top_level = false
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	var rec := MouseHelper.resolve_drag_target(self.drag_mask)
	self.drag_end.emit(rec)
