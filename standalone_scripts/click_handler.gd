## click_handler.gd
@tool
class_name Clickable
extends Node

@export var use_signal: bool = true
@export var use_method: bool = true
@export_enum("LEFT", "RIGHT", "BOTH") var button: int = 0

signal clicked

var _is_pressed: bool = false


func _ready() -> void:
	if Engine.is_editor_hint(): return
	self.get_parent().gui_input.connect(self._on_gui_input)
	self.get_parent().mouse_exited.connect(self._on_mouse_exited)


func _on_gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton: return

	var matches :bool = (self.button == 0 and event.button_index == MOUSE_BUTTON_LEFT) or \
				   		(self.button == 1 and event.button_index == MOUSE_BUTTON_RIGHT) or \
				   		(self.button == 2)

	if not matches: return

	if event.is_pressed():
		self._is_pressed = true
		return

	if not self._is_pressed: return
	self._is_pressed = false

	if self.use_signal:
		self.clicked.emit()

	if self.use_method:
		if self.get_parent().has_method("_on_clicked"):
			self.get_parent()._on_clicked()


func _on_mouse_exited() -> void:
	self._is_pressed = false
