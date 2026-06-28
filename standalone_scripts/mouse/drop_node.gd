class_name DropNode2D
extends Area2D

# On the dropnode 2D set layer to the drag mask value on the drag node.

@export_flags_2d_physics var drag_mask: int = 0

func _ready() -> void:
	print("global position ", self.global_position)
	