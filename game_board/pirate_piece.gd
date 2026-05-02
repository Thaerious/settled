class_name PiratePiece
extends Node2D

@onready var _sprite := %Sprite2DExact
@onready var _area2d := %Area2D

func _ready() -> void:
	self._area2d.input_event.connect(self._on_input_event)


func _on_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("_on_input_event")


func _input(event) -> void:
	if not event is InputEventMouseButton: return
	print("_input(%s)" % event)


func _unhandled_input(event) -> void:
	if not event is InputEventMouseButton: return
	print("_unhandled_input(%s)" % event)


# func _ready() -> void:
# 	print("area: ", self._area)
# 	print("input_pickable: ", self._area.input_pickable)
# 	# self.input_event.connect(self._on_input_event)
# 	print("connected: ", self._area.input_event.is_connected(self._on_input_event))


# func _input_event(event: InputEvent) -> void:
# 	print("input event")

# 	if not event is InputEventMouseButton: return
# 	if event.button_index != MouseButton.MOUSE_BUTTON_LEFT: return
# 	if not event.pressed: return

# 	var drag_args = DragArgs.new()
# 	drag_args.texture = self._sprite.texture
# 	drag_args.size = Vector2(64, 64)
# 	drag_args.offset = Vector2(-32, -32)
# 	drag_args.on_success = self._on_drop
# 	drag_args.on_failure = self._revert_drop

# 	self.visible = false

# 	MouseBus.start_drag(drag_args)



# func _on_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
# 	print("WOOT WOOT on input event")

# 	if not event is InputEventMouseButton: return
# 	if event.button_index != MouseButton.MOUSE_BUTTON_LEFT: return
# 	if not event.pressed: return

# 	var drag_args = DragArgs.new()
# 	drag_args.texture = self._sprite.texture
# 	drag_args.size = Vector2(64, 64)
# 	drag_args.offset = Vector2(-32, -32)
# 	drag_args.on_success = self._on_drop
# 	drag_args.on_failure = self._revert_drop

# 	self.visible = false

# 	MouseBus.start_drag(drag_args)


# func _on_drop(rec: DragRecord):
# 	var hex_tile = rec.destination.owner
# 	self.visible = true
# 	self.position = hex_tile.position
# 	print("Pirate Drop %s" % hex_tile)


# func _revert_drop(_rec: DragRecord):
# 	self.visible = true
