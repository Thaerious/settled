class_name StoreItemContainer
extends HBoxContainer

@onready var icon: TextureRect = $TextureRect

var enabled: bool = false:
	set(value):
		enabled = value
		if enabled:
			icon.modulate = Color(1.0, 1.0, 1.0, 1.0)
		else:
			icon.modulate = Color(0.5, 0.5, 0.5, 1.0)
