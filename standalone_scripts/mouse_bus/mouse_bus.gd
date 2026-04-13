## mouse_bus.gd (MouseBus)
## Autoload singleton that manages drag-and-drop and hover state for the entire game.
## Supports both Control (UI) and Area2D (world) drop targets via duck typing.
extends Node


## Configuration settings for drag-and-drop behaviour.
class DragSettings:
	## If [code]true[/code], the drag ghost is freed automatically when a drop occurs.
	var clear_on_drop: bool = true


## Active drag-and-drop settings instance.
var settings := DragSettings.new()


# ─── State ───

## The visual ghost node displayed under the cursor during a drag.
## [code]null[/code] when no drag is active.
var _draggable: TextureRect

## The data payload being carried by the current drag.
var _payload: Variant

## Called with a [DragRecord] when a drag completes successfully.
var _success_cb: Callable

## Called with a [DragRecord] when a drag fails to find a valid drop target.
var _failure_cb: Callable

## Offset from the cursor to the top-left of the drag ghost, set at drag start.
var _drag_offset: Vector2 = Vector2.ZERO

## The CanvasLayer that hosts the drag ghost, rendered above all other UI.
var _drag_layer: CanvasLayer = null

## The Control or Node currently under the cursor during a drag.
## [code]null[/code] when nothing is hovered.
var _hover_target: Node = null


# ─── Constants ───

## The CanvasLayer index used for the drag ghost. Renders above all UI.
const DRAG_LAYER: int = 10

## The mouse button that initiates and releases drags.
const DRAG_BUTTON: int = MouseButton.MOUSE_BUTTON_LEFT


# ─── Coordinate Helpers ───

## Returns the current mouse position in world space.
func mouse_world_pos() -> Vector2:
	return get_viewport().get_canvas_transform().affine_inverse() * get_viewport().get_mouse_position()


## Converts a canvas (screen) space position to world space.
## [param canvas_pos] The screen-space position to convert.
func world_pos(canvas_pos: Vector2) -> Vector2:
	return get_viewport().get_canvas_transform().affine_inverse() * canvas_pos


## Converts a world space position to canvas (screen) space.
## [param global_pos] The world-space position to convert.
func canvas_pos(global_pos: Vector2) -> Vector2:
	return get_viewport().get_canvas_transform() * global_pos


## Returns the mouse position in [param target]'s local coordinate space.
## Uses [method Control.get_local_mouse_position] for Control nodes,
## and [method Node2D.to_local] for everything else.
## [param target] The node to convert into.
## [param world_pos] The world-space position to convert.
func get_local(target: Variant, world_pos: Vector2) -> Vector2:
	if target is Control:
		return target.get_local_mouse_position()
	else:
		return target.to_local(world_pos)


# ─── Lifecycle ───

## Creates the drag [CanvasLayer] and resets the cursor to the default arrow shape.
func _ready() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	self._drag_layer = CanvasLayer.new()
	self._drag_layer.layer = DRAG_LAYER
	self.add_child(self._drag_layer)


## Listens for mouse button release to end an active drag.
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == DRAG_BUTTON and event.is_released():
			if self._draggable != null:
				self._stop_drag()


## Moves the drag ghost to follow the cursor and updates the hover target each frame.
func _process(_delta: float) -> void:
	if self._draggable == null: return
	self._draggable.position = get_viewport().get_mouse_position() + self._drag_offset
	var control := get_viewport().gui_get_hovered_control()
	self._update_hover_target(control)


# ─── Public API ───

## Begins a drag operation, creating a ghost image that follows the cursor.
## Asserts that no drag is already active.
##
## [param texture] The texture to display on the drag ghost.
## [param payload] Arbitrary data to deliver to the drop target.
## [param size] The display size of the drag ghost.
## [param offset] Offset from the cursor to the ghost's top-left corner.
## [param on_success] Callable invoked with a [DragRecord] on successful drop.
## [param on_failure] Callable invoked with a [DragRecord] when no valid target is found.
func start_drag(
	texture:    Texture2D,
	payload:    Variant,
	size:       Vector2,
	offset:     Vector2 = Vector2.ZERO,
	on_success: Callable = Callable(),
	on_failure: Callable = Callable(),
) -> void:
	assert(self._draggable == null, "MouseBus: drag started while one is already active")

	self._draggable  = self._generate_rect(texture, size)
	self._payload    = payload
	self._success_cb = on_success
	self._failure_cb = on_failure
	self._drag_offset = offset
	self._drag_layer.add_child(self._draggable)


## Returns whether a drag is currently in progress.
func is_dragging() -> bool:
	return self._draggable != null


## Frees the drag ghost immediately if one exists.
## Does not resolve drop targets or invoke callbacks.
func clear_image() -> void:
	if self._draggable != null:
		self._draggable.queue_free()


# ─── Internals ───

## Creates and returns a [TextureRect] configured as a drag ghost.
## Mouse filter is set to [constant Control.MOUSE_FILTER_IGNORE] so it does
## not interfere with hover detection on nodes beneath it.
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


## Queries the 2D physics space at [param world] for Area2D nodes that implement [code]on_drop[/code].
## Checks the collider directly, then falls back to its parent.
## [param world] The world-space position to query.
func _get_drop_targets_at(world: Vector2) -> Array[Node]:
	var targets: Array[Node] = []
	var space := get_viewport().get_world_2d().direct_space_state
	var query := PhysicsPointQueryParameters2D.new()
	query.position = world
	query.collide_with_areas = true
	query.collide_with_bodies = false

	var results := space.intersect_point(query)

	for result in results:
		var collider = result.collider
		if collider.has_method("on_drop"):
			targets.append(collider)
		elif collider.get_parent().has_method("on_drop"):
			targets.append(collider.get_parent())

	return targets


## Resolves the drop target under the cursor and returns a populated [DragRecord].
## Checks UI controls first via [method Viewport.gui_get_hovered_control],
## then falls back to physics-based Area2D targets.
## Calls [code]on_drop(record)[/code] on the target if found.
func _resolve_drop_target() -> DragRecord:
	var screen_pos := get_viewport().get_mouse_position()
	var world := self.world_pos(screen_pos)

	var record := DragRecord.new(
		self._draggable,
		self._payload,
		screen_pos,
		world,
	)

	var drop_target: Variant = get_viewport().gui_get_hovered_control()

	if drop_target == null:
		var node_targets := self._get_drop_targets_at(world)
		if node_targets.size() > 0: drop_target = node_targets[0]

	if drop_target == null:
		return record

	record.destination = drop_target
	record.local_position = self.get_local(drop_target, world)

	if drop_target.has_method("on_drop"):
		record.succeeded = drop_target.on_drop(record)

	if self.settings.clear_on_drop:
		self.clear_image()

	return record


## Ends the active drag, resolves the drop target, and invokes the appropriate callback.
## Also notifies the current hover target via [code]on_drag_exit[/code] if implemented.
func _stop_drag() -> void:
	if self._draggable == null: return
	var record = self._resolve_drop_target()

	if record.succeeded and self._success_cb.is_valid():
		self._success_cb.call(record)
	elif not record.succeeded and self._failure_cb.is_valid():
		self._failure_cb.call(record)

	if self._hover_target != null and self._hover_target.has_method("on_drag_exit"):
		var hover_record := self._build_hover_record(self._hover_target)
		self._hover_target.on_drag_exit(hover_record)

	self._draggable = null
	self._hover_target = null
	self._drag_offset = Vector2.ZERO


## Updates [member _hover_target] as the cursor moves during a drag.
## Calls [code]on_drag_exit[/code] on the previous target and [code]on_drag_enter[/code]
## on the new target if those methods exist.
## [param control] The Control currently under the cursor, or [code]null[/code].
func _update_hover_target(control: Control) -> void:
	if control == self._hover_target: return

	if self._hover_target != null and self._hover_target.has_method("on_drag_exit"):
		var hover_record := self._build_hover_record(self._hover_target)
		self._hover_target.on_drag_exit(hover_record)

	self._hover_target = control

	if self._hover_target != null and self._hover_target.has_method("on_drag_enter"):
		var hover_record := self._build_hover_record(self._hover_target)
		self._hover_target.on_drag_enter(hover_record)


## Constructs a [DragRecord] describing the current drag state relative to [param target].
## Used internally to populate hover enter/exit callbacks.
## [param target] The node to use as the record's destination.
func _build_hover_record(target: Node) -> DragRecord:
	var screen_pos := get_viewport().get_mouse_position()
	var world := self.world_pos(screen_pos)

	var record := DragRecord.new(
		self._draggable,
		self._payload,
		screen_pos,
		world,
	)

	record.destination = target
	record.local_position = self.get_local(target, world)
	return record