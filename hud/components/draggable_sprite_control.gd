@tool
class_name DraggableSpriteControl
extends DialogSpriteControl

@onready var drag_node = %DragNodeUI

@export var drop_layer: int = 0:
	set(value):
		drop_layer = value		
		if not is_node_ready(): return
		%DragNodeUI.drop_layer = value


@export var sprite_texture: Texture2D:
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


func _post_ready() -> void:
	super._post_ready()
	%ScaledSprite.texture = self.sprite_texture
	%ScaledSprite.sprite_size = self.sprite_size
	%DragNodeUI.drop_layer = self.drop_layer


func _enable() -> void: 
	super._enable()
	%DragNodeUI.disabled = false


func _disable() -> void:	
	if self.name == "HouseControl": print("draggable_dialog_control._disable() (%s)" % [self.name])
	super._disable()
	%DragNodeUI.disabled = true
