class_name DragNode2D
extends Node

signal drag_start()
signal drag_end(rec: DragRecord)
signal hover_enter(rec: DragRecord)
signal hover_exit(rec: DragRecord)

var _last_hover_target: Node = null
var _dragging := false

@export var drag_target: Node2D = null
@export var disabled = false
@export_flags_2d_physics var drag_mask: int = 1


func _ready() -> void:
	self.get_parent().input_event.connect(self._on_press)


func _process(_delta: float) -> void:
	if not self._dragging: return
	# self.drag_target.global_position = get_global_mouse_position()
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


func _on_press(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if self.disabled: return
	if not event is InputEventMouseButton: return
	if not MouseHelper.is_left_press(event): return
	if self._dragging: return

	self._do_start_drag()


func _do_start_drag() -> void:
	self._dragging = true
	self.drag_target.visible = true
	self.drag_target.top_level = true
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	self.drag_start.emit()


func _do_stop_drag() -> void:
	self._dragging = false
	self.drag_target.visible = false
	self.drag_target.top_level = false
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	var rec := MouseHelper.resolve_drag_target(self.drag_mask)
	self.drag_end.emit(rec)