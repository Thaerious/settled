class_name NumberPiece
extends Node2D

@onready var number_label: Label = %NumberLabel
var axial: Axial = null


@export var number: int = 7:
	set(value):
		number = value
		if self.is_node_ready():
			number_label.text = str(value)


func _ready() -> void:
	self.number = self.number
