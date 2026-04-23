@tool
class_name Sprite2DExact
extends Sprite2D

@export var sprite_size: Vector2:
    set(value):
        sprite_size = value
        self._apply_scale()


func _ready() -> void:
    self._apply_scale()


func set_texture_exact(tex: Texture2D) -> void:
    self.texture = tex
    self._apply_scale()


func _apply_scale() -> void:
    if self.texture and self.sprite_size != Vector2.ZERO:
        self.scale = self.sprite_size / self.texture.get_size()