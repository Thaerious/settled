class_name DragNode
extends Node

var _dragging := false
@export var enabled = true
@export_flags_2d_physics var drag_mask: int = 1

# connect a press handler to trigger that is invoked on a LMB press
func _ready() -> void:
	self.get_parent()
	self.get_parent().gui_input.connect(self._on_press)
	

## Moves the drag ghost to follow the cursor and updates the hover target each frame.
func _process(_delta: float) -> void:
	if not self._dragging: return
	$Sprite.global_position = get_viewport().get_mouse_position()	


func _on_press(event: InputEvent) -> void:	
	if not self.enabled: return
	if not event is InputEventMouse: return
	if is_left_press(event): 
		if not self._dragging: self._do_start_drag()

	if is_left_release(event):		
		if self._dragging: self._do_stop_drag()


func _do_start_drag() -> void:
	self._dragging = true
	$Sprite.visible = true
	$Sprite.top_level = true
	self.on_start()


## Ends the active drag, resolves the drop target, and invokes the appropriate callback.
func _do_stop_drag() -> void:
	self._dragging = false
	$Sprite.visible = false
	$Sprite.top_level = false
	var rec := MouseHelper.resolve_target(self.drag_mask)

	# print("mouse screen: ", get_viewport().get_mouse_position())
	# # print("drop_node global_position: ", drop_node.global_position)
	# print("screen_transform: ", get_viewport().get_screen_transform())
	# print("canvas_transform: ", get_viewport().get_canvas_transform())


func on_start() -> void:
	pass


func on_finish(rec: DragRecord) -> void:
	pass


func _on_enter(_rec: HoverRecord) -> void:
	pass


func _on_exit(_rec: HoverRecord) -> void:
	pass


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
