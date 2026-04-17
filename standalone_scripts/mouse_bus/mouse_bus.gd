## mouse_bus.gd (MouseBus)
## Autoload singleton that manages drag-and-drop and hover state for the entire game.
## Supports both Control (UI) and Area2D (world) drop targets.
extends Node


# ─── Constants ───

## The CanvasLayer index used for the drag ghost. Renders above all UI.
const DRAG_LAYER: int = 10

## The mouse button that initiates and releases drags.
const DRAG_BUTTON: int = MouseButton.MOUSE_BUTTON_LEFT

# ─── State ───

## Bitmask for physics layer
var _mouse_mask: int = 0

## The active drag arguments. [code]null[/code] when no drag is active.
var _args: DragArgs = null

## The visual ghost node displayed under the cursor during a drag.
var _draggable: TextureRect = null

## The CanvasLayer that hosts the drag ghost, rendered above all other UI.
var _drag_layer: CanvasLayer = null

## The node currently under the cursor during a drag.
## [code]null[/code] when nothing is hovered.
var _hover_target: Node = null


# ─── Lifecycle ───

## Creates the drag [CanvasLayer] and resets the cursor to the default arrow shape.
func _ready() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	self._drag_layer = CanvasLayer.new()
	self._drag_layer.layer = DRAG_LAYER
	self.add_child(self._drag_layer)
	self._mouse_mask = self._get_mouse_mask()


## Listens for mouse button release to end an active drag.
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == DRAG_BUTTON and event.is_released():
			if self._draggable != null:
				self._stop_drag()


## Moves the drag ghost to follow the cursor and updates the hover target each frame.
func _process(_delta: float) -> void:
	if self._draggable == null: return
	self._draggable.position = get_viewport().get_mouse_position() + self._args.offset
	self._update_hover()


# ─── Public API ───

## Begins a drag operation, creating a ghost image that follows the cursor.
## Asserts that no drag is already active.
## [param args] The drag configuration and callbacks.
func start_drag(args: DragArgs) -> void:
	assert(self._draggable == null, "MouseBus: drag started while one is already active")
	self._args      = args
	self._draggable = self._generate_rect(args.texture, args.size)
	self._drag_layer.add_child(self._draggable)


## Returns whether a drag is currently in progress.
func is_dragging() -> bool:
	return self._draggable != null


## Frees the drag ghost if one exists. Does not resolve drop targets or invoke callbacks.
func clear_image() -> void:
	if self._draggable != null:
		self._draggable.queue_free()
		self._draggable = null


# ─── Coordinate Helpers ───

## Returns the current mouse position in world space.
func mouse_world_pos() -> Vector2:
	return get_viewport().get_canvas_transform().affine_inverse() * get_viewport().get_mouse_position()


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


# ─── Internals ───

func _get_mouse_mask() -> int:
	for i in range(32):
		if ProjectSettings.get_setting("layer_names/2d_physics/layer_%d" % (i + 1)).to_lower() == "mouse":
			return 1 << i
	push_error("MouseBus: no physics layer named 'mouse' found")
	return 0


## Creates and returns a [TextureRect] configured as a drag ghost.
## [param texture] The texture to display.
## [param size] The minimum size of the rect.
func _generate_rect(texture: Texture2D, size: Vector2) -> TextureRect:
	var texture_rect := TextureRect.new()
	texture_rect.texture = texture
	texture_rect.custom_minimum_size = size
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return texture_rect


## Queries the physics space at [param world] for Area2D nodes on the mouse layer.
## [param world] The world-space position to query.
func _get_world_target(world: Vector2) -> Node:
	var targets: Array[Node] = []
	var space := get_viewport().get_world_2d().direct_space_state
	var query := PhysicsPointQueryParameters2D.new()
	query.position = world
	query.collide_with_areas = true
	query.collide_with_bodies = false	
	query.collision_mask = self._mouse_mask

	for result in space.intersect_point(query):
		targets.append(result.collider)

	if targets.size() > 0: return targets[0]
	return null


## Any control that accepts drop declares 'var can_drop: bool = true'
func _get_ui_target() -> Control:
	var ui_target: Control = get_viewport().gui_get_hovered_control()
	if ui_target == null: return null
	if not "can_drop" in ui_target: return null
	if not ui_target.can_drop: return null
	return ui_target


# Retrieve the first object under the mouse that is a valid target for drag-drop
func _get_drop_target(world: Vector2) -> Variant:
	var drop_target: Variant = self._get_ui_target()
	if drop_target != null: return drop_target
	return self._get_world_target(world)


## Resolves the drop target under the cursor and returns a populated [DragRecord].
## Checks UI controls first, then falls back to physics-based Area2D targets.
func _resolve_target() -> DragRecord:
	var screen_pos := get_viewport().get_mouse_position()
	var world      := self.world_pos(screen_pos)

	var record := DragRecord.new()
	record.draggable      = self._draggable
	record.payload        = self._args.payload
	record.screen_pos     = screen_pos
	record.world_pos      = world
	record.destination    = self._get_drop_target(world)

	if record.destination != null:
		record.local_pos = self.get_local(record.destination, world)

	return record


## Ends the active drag, resolves the drop target, and invokes the appropriate callback.
func _stop_drag() -> void:
	if self._draggable == null: return
	var record := self._resolve_target()
	
	if self._hover_target != null:
		var hover := HoverRecord.new()
		hover.draggable  = self._draggable
		hover.payload    = self._args.payload
		hover.screen_pos = record.screen_pos
		hover.world_pos  = record.world_pos
		hover.exited     = self._hover_target
		hover.entered    = null

	if record.destination: 
		self._args.on_success.call(record)
	else: 
		self._args.on_failure.call(record)

	self.clear_image()
	self._args         = null
	self._hover_target = null


func _generate_hover_record() -> HoverRecord:
	var record := HoverRecord.new()
	record.draggable  = self._draggable
	record.payload    = self._args.payload
	record.screen_pos = get_viewport().get_mouse_position()
	record.world_pos  = self.world_pos(record.screen_pos)
	record.exited     = self._hover_target
	record.entered    = self._get_drop_target(record.world_pos)
	return record

## Updates [member _hover_target] as the cursor moves during a drag.
## Invokes [member DragArgs.on_exit] and [member DragArgs.on_enter] as the target changes.
## [param control] The Control currently under the cursor, or [code]null[/code].
func _update_hover() -> void:
	var record = self._generate_hover_record()
	if record.exited == record.entered: return
	if record.entered: self._args.on_enter.call(record)
	if record.exited: self._args.on_exit.call(record)
	self._hover_target = record.entered
