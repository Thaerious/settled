class_name DialogFrame
extends DialogContainer

static var z_index_dictionary = {}


@export var dialog_identifier := ""
@export var draggable := true
var _dragging := false
var _drag_offset := Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	if self.dialog_identifier == "": self.dialog_identifier = self.name
	self.load_pos()
	%Title.gui_input.connect(self._on_mouse_input)


func _process(_delta: float) -> void:
	if not self._dragging: return
	self.global_position = get_global_mouse_position() - self._drag_offset


func _on_mouse_input(event: InputEvent) -> void:
	if not self.draggable: return
	if not event is InputEventMouseButton: return
	
	if MouseHelper.is_left_press(event):
		if not self._dragging: self._do_start_drag()

	if MouseHelper.is_left_release(event):
		if self._dragging: self._do_stop_drag()


func _do_start_drag() -> void:
	self._dragging = true
	self._drag_offset = get_global_mouse_position() - self.global_position
	%Title.set_default_cursor_shape(Input.CURSOR_DRAG)

	for item in DialogFrame.z_index_dictionary.keys():
		item.z_index -= 1

	self.float_to_top()
	DialogFrame.z_index_dictionary[self] = self


func float_to_top() -> void:
	self.move_to_front()


func _do_stop_drag() -> void:
	self._dragging = false
	%Title.set_default_cursor_shape(Input.CURSOR_ARROW)
	self.save_pos()


func save_pos() -> void:
	var config := ConfigFile.new()
	config.load("user://settings.cfg")
	config.set_value("dialog_pos", self.dialog_identifier, self.global_position)
	config.save("user://settings.cfg")


func load_pos() -> void:
	var config := ConfigFile.new()
	config.load("user://settings.cfg")
	if not config.has_section_key("dialog_pos", self.dialog_identifier): return
	self.global_position = config.get_value("dialog_pos", self.dialog_identifier)	