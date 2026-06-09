## game.gd
class_name GameInstance
extends Node

var model: Model = null
var self_id: int = 0
var player_count: int = 4
var names: Array[String] = ["Adam", "Barney", "Charles III", "Diana"]

func _ready() -> void:
	self.model = Model.new()
	self.model.build(names)

	EventBus.set_player_view.connect(func(id: int): 
		self.self_id = id
		EventBus.player_view_set.emit(id)
		EventBus.model_loaded.emit()
	)

	self.call_deferred("_emit_initial_state")


func reset() -> void:
	self.model = Model.new()
	self.model.build(names)
	self.call_deferred("_emit_initial_state")


func _emit_initial_state() -> void:
	EventBus.model_loaded.emit()
