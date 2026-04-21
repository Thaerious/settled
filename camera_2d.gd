## map_camera.gd
extends Camera2D

@export var zoom_step: float = 0.1
@export var zoom_min: float = 0.5
@export var zoom_max: float = 3.0

var _dragging: bool = false
var _drag_start: Vector2 = Vector2.ZERO


func _ready():
	self.load_state()


func save_state() -> void:
	var config := ConfigFile.new()
	config.set_value("camera", "zoom", self.zoom)
	config.set_value("camera", "position", self.global_position)
	config.save("user://camera.cfg")


func load_state() -> void:
	var config := ConfigFile.new()
	if config.load("user://camera.cfg") == OK:
		self.global_position = config.get_value("camera", "position", Vector2.ZERO)
		self.zoom = config.get_value("camera", "zoom", Vector2(1, 1))

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:			
			self._dragging = event.pressed
			self._drag_start = get_viewport().get_mouse_position()
			
			if event.is_pressed():
				Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			self.zoom = (self.zoom + Vector2.ONE * self.zoom_step).clamp(
				Vector2.ONE * self.zoom_min,
				Vector2.ONE * self.zoom_max
			)

		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			self.zoom = (self.zoom - Vector2.ONE * self.zoom_step).clamp(
				Vector2.ONE * self.zoom_min,
				Vector2.ONE * self.zoom_max
			)

	elif event is InputEventMouseMotion:
		if self._dragging:
			var current := get_viewport().get_mouse_position()
			self.global_position -= (current - self._drag_start) / self.zoom
			self._drag_start = current

	self.save_state()