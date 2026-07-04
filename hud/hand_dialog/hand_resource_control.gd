@tool
class_name HandResourceControl
extends DialogControl

@onready var _drag_node := $DragNode

@export var resource_type: Model.ResourceTypes = Model.ResourceTypes.NONE


@export var sprite_texture : Texture2D:
	set(value):
		sprite_texture = value		
		if not is_node_ready(): return
		%ScaledSprite.texture = value


@export var sprite_size := Vector2(50, 50):	
	set(value):
		sprite_size = value
		if not is_node_ready(): return
		if not self.sprite_texture: return
		if value == Vector2.ZERO: return
		%ScaledSprite.sprite_size = value


func _ready() -> void:
	super._ready()

	self.sprite_texture = self.sprite_texture
	self.sprite_size = self.sprite_size


func _on_mouse_entered() -> void:	
	if disabled: return
	self._style_helper.style = "hover"


func _on_mouse_exited() -> void:	
	if disabled: return
	self._style_helper.style = "default"


func _on_drag_start():
	pass # Replace with function body.
