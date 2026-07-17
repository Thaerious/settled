extends Node

## The mouse button that initiates and releases drags.
const DRAG_BUTTON: int = MouseButton.MOUSE_BUTTON_LEFT
const MASK: int = 4294967295


## Converts a canvas (screen) space position to world space.
## [param canvas_pos] The screen-space position to convert.
func world_pos(canvas_pos_in: Vector2) -> Vector2:
	return get_viewport().get_canvas_transform().affine_inverse() * canvas_pos_in


## Converts a world space position to canvas (screen) space.
## [param global_pos] The world-space position to convert.
func canvas_pos(global_pos: Vector2) -> Vector2:
	return get_viewport().get_canvas_transform() * global_pos


## Returns the mouse position in [param target]'s local coordinate space.
## [param target] The node to convert into.
## [param world_pos] The world-space position to convert.
func get_local(target: Variant, world_pos_in: Vector2) -> Vector2:
	if target is Control:
		return target.get_local_mouse_position()
	else:
		return target.to_local(world_pos_in)


## Queries the game space for Area2D nodes whose collision LAYER
## matches drag_layer (the query's collision_mask).
## drag_layer is set on the drag node.
func _get_world_target(world: Vector2, drag_layer: int) -> Node:
	var targets: Array[Node] = []
	var space := get_viewport().get_world_2d().direct_space_state
	var query := PhysicsPointQueryParameters2D.new()

	query.position = world
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.collision_mask = drag_layer

	for result in space.intersect_point(query):
		targets.append(result.collider)

	print(drag_layer, targets)
	if targets.size() > 0: 
		return targets[0]
	
	return null



## Queries the ui space for any node with a drag_layer field.
## Matches with Nodes whose drag_layer matches the drag_layer 
## from the source drag node.
func get_ui_target(drag_layer: int) -> Control:
	var ui_target: Control = get_viewport().gui_get_hovered_control()
	if ui_target == null: return null

	# A drop target MUST have a drag_layer:int field
	if not "drop_mask" in ui_target: return null
	if not ui_target.drag_layer and drag_layer: return null
	
	# If the drop target has an on_drop:bool method only accept the drop
	# if the method returns true.
	if "on_drop" in ui_target and not ui_target.on_drop(): return null
	
	return ui_target


# Retrieve the first object under the mouse that is a valid target for drag-drop
# A valid target for drag-drop is either a ui control with a drag mask field that
# intersects passed in drag_layer, or a world node with a collision area that has an
# intersecting collision layer. 
func _get_drop_target(world: Vector2, drag_layer: int) -> Variant:
	var drop_target: Variant = self.get_ui_target(drag_layer)
	if drop_target != null: return drop_target
	return self._get_world_target(world, drag_layer)


## Resolves the drop target under the cursor and returns a populated [DragRecord].
## Checks UI controls first, then falls back to physics-based Area2D targets.
func resolve_drag_target(drag_layer: int) -> DragRecord:
	var screen_pos := get_viewport().get_mouse_position()
	var world      := self.world_pos(screen_pos)

	var record := DragRecord.new()
	record.screen_pos     = screen_pos
	record.world_pos      = world
	record.drop_target    = self._get_drop_target(world, drag_layer)

	if record.drop_target != null:
		record.local_pos = self.get_local(record.drop_target, world)

	return record


func is_left_press(event: InputEvent) -> bool:
	return (
		event is InputEventMouseButton
		and event.button_index == MouseButton.MOUSE_BUTTON_LEFT
		and event.pressed
	)	


func is_left_release(event: InputEvent) -> bool:
	return (
		event is InputEventMouseButton
		and event.button_index == MouseButton.MOUSE_BUTTON_LEFT
		and not event.pressed
	)		

