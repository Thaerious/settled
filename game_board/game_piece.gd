class_name GamePiece
extends Node2D

@onready var _sprite_node := %Sprite2D

@export var texture: Texture2D:
	set(value):
		texture = value
		if self.is_node_ready():
			self._sprite_node.texture = value


@export var sprite_size: Vector2:
	set(value):
		sprite_size = value
		if self.is_node_ready() and self.texture:
			self._sprite_node.scale = self.sprite_size / self.texture.get_size()


func _ready() -> void:
	if self.texture:
		self._sprite_node.texture = self.texture
		self._sprite_node.scale = self.sprite_size / self.texture.get_size()
