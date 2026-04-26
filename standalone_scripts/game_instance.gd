## game.gd
class_name GameInstance
extends Node

var model: Model = null
var self_id: int = 0

func _ready() -> void:
	self.model = Model.new()
