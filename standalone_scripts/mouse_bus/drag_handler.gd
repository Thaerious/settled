class_name DragHandler
extends RefCounted

## The texture used for the drag ghost. Assign in subclass or before first drag.
## If null, the ghost renders as an empty rect and the mouse isn't hidden.
var texture: Texture2D = null
var texture_size := Vector2(32,32)

var _trigger: Control
var _args: DragArgs


func _init(trigger: Control) -> void:
	self._trigger = trigger
	self._trigger.gui_input.connect(self._on_press)

	self._args = DragArgs.new()
	_args.on_success = self._on_success
	_args.on_failure = self._on_failure
	_args.on_enter = self._on_enter
	_args.on_exit = self._on_exit
	

func _on_press(event: InputEvent) -> void:	
	if not event is InputEventMouse: return
	if is_left_click(event): self._start_drag()


func _start_drag() -> void:
	if self.texture != null:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		_args.texture = self.texture
		_args.size = self.texture_size	
	MouseBus.start_drag(self._args)


func _on_success(_rec: DragRecord) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_failure(_rec: DragRecord) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_enter(_rec: HoverRecord) -> void:
	pass


func _on_exit(_rec: HoverRecord) -> void:
	pass


static func is_left_click(event: InputEvent) -> bool:
	return (
		event is InputEventMouseButton
		and event.button_index == MouseButton.MOUSE_BUTTON_LEFT
		and event.pressed
	)	