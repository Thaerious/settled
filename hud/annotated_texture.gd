@tool
class_name AnnotatedTexture
extends PanelContainer

@onready var texture_rect: TextureRect = %TextureRect
@onready var label: Label = %Label

@export var texture: Texture2D:
    set(value):
        texture = value
        if self.texture_rect:
            self.texture_rect.texture = value


@export var text: String = "0":
    set(value):
        text = value
        if self.label:
            self.label.text = value


func _ready() -> void:
    if self.texture_rect:
        self.texture_rect.texture = self.texture
    if self.label:
        self.label.text = self.text