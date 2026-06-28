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


## Queries the physics space at [param world] for Area2D nodes on the mouse layer.
## [param world] The world-space position to query.
func _get_world_target(world: Vector2) -> Node:
	var targets: Array[Node] = []
	var space := get_viewport().get_world_2d().direct_space_state
	var query := PhysicsPointQueryParameters2D.new()

	query.position = world
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.collision_mask = self.MASK

	for result in space.intersect_point(query):
		targets.append(result.collider)

	if targets.size() > 0: return targets[0]
	return null


func _get_ui_target(src_mask: int) -> Control:
	var ui_target: Control = get_viewport().gui_get_hovered_control()
	if ui_target == null: return null

	# A drop target MUST have a drag_mask:int field
	if not "drag_mask" in ui_target: return null
	if not ui_target.drag_mask and src_mask: return null
	
	# If the drop target has an on_drop:bool method only accept the drop
	# if the method returns true.
	if "on_drop" in ui_target and not ui_target.on_drop(): return null
	
	return ui_target


func _get_drop_node(control: Control) -> DropNode2D:
	while control != null:
		var drop_node := control.find_child("DropNode2D")
		if drop_node != null:
			return drop_node
		control = control.get_parent() as Control
	return null

# Retrieve the first object under the mouse that is a valid target for drag-drop
func _get_drop_target(world: Vector2, src_mask: int) -> Variant:
	var drop_target: Variant = self._get_ui_target(src_mask)
	if drop_target != null: return drop_target
	return self._get_world_target(world)


## Resolves the drop target under the cursor and returns a populated [DragRecord].
## Checks UI controls first, then falls back to physics-based Area2D targets.
func resolve_target(src_mask: int) -> DragRecord:
	var screen_pos := get_viewport().get_mouse_position()
	var world      := self.world_pos(screen_pos)

	var record := DragRecord.new()
	record.screen_pos     = screen_pos
	record.world_pos      = world
	record.destination    = self._get_drop_target(world, src_mask)

	if record.destination != null:
		record.local_pos = self.get_local(record.destination, world)

	return record


func _generate_hover_record(src_mask: int) -> HoverRecord:
	var record := HoverRecord.new()
	record.screen_pos = get_viewport().get_mouse_position()
	record.world_pos  = self.world_pos(record.screen_pos)
	record.exited     = self._hover_target
	record.entered    = self._get_drop_target(record.world_pos, src_mask)
	return record

## Updates [member _hover_target] as the cursor moves during a drag.
## Invokes [member DragArgs.on_exit] and [member DragArgs.on_enter] as the target changes.
## [param control] The Control currently under the cursor, or [code]null[/code].
func _update_hover(src_mask: int) -> void:
	var record = self._generate_hover_record(src_mask)
	if record.exited == record.entered: return
	if record.entered: self._args.on_enter.call(record)
	if record.exited: self._args.on_exit.call(record)
	self._hover_target = record.entered
