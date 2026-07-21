@tool
class_name DraggableDialogSpriteControl
extends DialogSpriteControl

@onready var _drag_node := %DragNodeUI
@export var drag_layer := 1


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


func _enable() -> void: 
	super._enable()
	self._drag_node.disabled = false


func _disable() -> void:	
	super._disable()
	self._drag_node.disabled = true
