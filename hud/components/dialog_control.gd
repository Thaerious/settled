@tool
class_name DialogControl
extends PanelContainer

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
		disabled = v
		if not is_node_ready(): return
		if disabled: self._disable()
		else: self._enable()


func _ready() -> void:
	self.sprite_texture = self.sprite_texture
	self.sprite_size = self.sprite_size


func _on_mouse_entered() -> void:	
	if disabled: return
	self._style_helper.style = "hover"


func _on_mouse_exited() -> void:	
	if disabled: return
	self._style_helper.style = "default"


func _enable() -> void: 
	self._style_helper.style = "default"


func _disable() -> void:	
	self._style_helper.style = "disabled"
