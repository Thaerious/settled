class_name DragHandler
extends Object

## Set texture & texture_size for the drag ghost. Assign in subclass.
## If not set, the ghost renders as an empty rect and the mouse isn't hidden.
# var texture: Texture2D = null
# var texture_size := Vector2(32,32)

var _trigger: Control
var _args: DragArgs

var mask = 0x01
var enabled = true


# connect a press handler to trigger that is invoked on a LMB press
func _init(trigger: Control) -> void:
	self._trigger = trigger
	self._trigger.gui_input.connect(self._on_press)
	self._args = DragArgs.new()

	_args.on_success = func(rec):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		self._on_success(rec)

	_args.on_failure = func(rec):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		self._on_failure(rec)

	_args.on_enter = self._on_enter
	_args.on_exit = self._on_exit
	_args.mask = self.mask
	

func _on_press(event: InputEvent) -> void:	
	if not self.enabled: return
	if not event is InputEventMouse: return
	if is_left_press(event): self._do_start_drag()


func _do_start_drag() -> void:
	if "texture" in self and "texture_size" in self:
		# Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		self._args.texture = self.texture
		self._args.size    = self.texture_size	
		self._args.offset  = self.texture_size / -2	
		self._args.mask    = self.mask

	self._start_drag()
	MouseBus.start_drag(self._args)


func _start_drag() -> void:
	pass


func _on_success(_rec: DragRecord) -> void:
	pass


func _on_failure(_rec: DragRecord) -> void:
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
