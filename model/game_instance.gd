## game.gd
class_name GameInstance
extends Node

var model: Model = null
var self_id: int = 0
var player_count: int = 4

func _ready() -> void:
	self.model = Model.new()
	EventBus.set_player_view.connect(func(id: int): self.self_id = id)
