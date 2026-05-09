## game.gd
class_name GameInstance
extends Node

var model: Model = null
var self_id: int = 0
var player_count: int = 4

func _ready() -> void:
	self.model = Model.new()

	# todo this get's replaced by the game genertor
	self.model.player_names = ["Adam", "Barney", "Charles III", "Diana"]

	EventBus.set_player_view.connect(func(id: int): self.self_id = id)
	self.call_deferred("_emit_initial_state")


func reset() -> void:
	self.model = Model.new()
	self.model.player_names = ["Adam", "Barney", "Charles III", "Diana"]
	self.call_deferred("_emit_initial_state")


func _emit_initial_state() -> void:
	self.model.do_update_player(0)
	self.model.do_update_phase(Model.GamePhase.NOT_STARTED)
	EventBus.model_loaded.emit()
