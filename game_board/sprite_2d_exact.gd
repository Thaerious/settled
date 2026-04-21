@tool
class_name Sprite2DExact
extends Sprite2D


@export var sprite_size: Vector2:
	set(value):
		sprite_size = value
		if self.is_node_ready() and self.texture:
			self.scale = self.sprite_size / self.texture.get_size()


func _ready() -> void:
	if self.texture:
		self.texture = self.texture
		self.scale = self.sprite_size / self.texture.get_size()