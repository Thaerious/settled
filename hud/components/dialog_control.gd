@tool
class_name DialogControl
extends PanelContainer

signal clicked()

var _hover := false
@onready var _style_helper := %StyleHelper

@export var display_texture : Texture2D:
	set(value):
		display_texture = value
		if not is_node_ready(): return	
		%IconTexture.texture = value


@export var disabled := false:
	get: 
		return disabled
	set(v): 
		if disabled == v: return
		disabled = v		
		if not is_node_ready(): return
		self._update_style()


func _ready() -> void:
	self.display_texture = self.display_texture
	self.mouse_entered.connect(self._on_mouse_entered)
	self.mouse_exited.connect(self._on_mouse_exited)
	self.gui_input.connect(self._on_press)
	self._update_style()


func _on_press(event: InputEvent) -> void:
	if self.disabled: return
	if not event is InputEventMouseButton: return
	if not MouseHelper.is_left_release(event): return
	if not get_viewport().gui_get_hovered_control(): return
	if not get_viewport().gui_get_hovered_control().owner == self: return

	self.clicked.emit()

func _on_mouse_entered() -> void:	
	self._hover = true
	self._update_style()


func _on_mouse_exited() -> void:	
	self._hover = false
	self._update_style()


func _update_style() -> void:
	if self.disabled: 
		self.mouse_default_cursor_shape = Control.CURSOR_ARROW
		self._style_helper.style = "default"
	elif self._hover:
		self.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND	
		self._style_helper.style = "hover"
	else:
		self.mouse_default_cursor_shape = Control.CURSOR_ARROW
		self._style_helper.style = "default"					


func _enable() -> void: 
	self._style_helper.style = "default"


func _disable() -> void:	
	self._style_helper.style = "disabled"


func _select() -> void: 
	self._style_helper.style = "selected"


func _deselect() -> void:	
	self._style_helper.style = "default"
