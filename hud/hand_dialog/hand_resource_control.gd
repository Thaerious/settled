@tool
class_name HandResourceControl
extends PanelContainer

@onready var _style_helper := $StyleHelper
@onready var _drag_node := $DragNode

@export var resource_type: Model.ResourceTypes = Model.ResourceTypes.NONE


@export var display_texture : Texture2D:
	set(value):
		display_texture = value		
		if not is_node_ready(): return
		%ResourceTexture.texture = value


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


@export var disabled := false:
	get: return disabled
	set(v): 
		disabled = v
		if not is_node_ready(): return
		self._drag_node.disabled = v

		if disabled: 
			self._style_helper.style = "disabled"
		else: 
			self._style_helper.style = "default"


func _ready() -> void:
	self.display_texture = self.display_texture
	self.sprite_texture = self.sprite_texture
	self.sprite_size = self.sprite_size
	self.disabled = self.disabled

	if Engine.is_editor_hint(): return
	self.mouse_entered.connect(self._on_mouse_entered)
	self.mouse_exited.connect(self._on_mouse_exited)


func _on_mouse_entered() -> void:	
	if disabled: return
	self._style_helper.style = "hover"


func _on_mouse_exited() -> void:	
	if disabled: return
	self._style_helper.style = "default"


func _on_drag_start():
	pass # Replace with function body.
