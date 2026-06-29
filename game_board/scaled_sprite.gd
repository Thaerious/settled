class_name ScaledSprite
extends Sprite2D


@export var sprite_size: Vector2:
	set(value):
		sprite_size = value
		if self.is_node_ready() and self.texture and value != Vector2.ZERO:
			self.scale = value / self.texture.get_size()


func _ready() -> void:
	if self.texture and self.sprite_size != Vector2.ZERO:
		self.scale = self.sprite_size / self.texture.get_size()
