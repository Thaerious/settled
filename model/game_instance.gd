## game.gd
class_name GameInstance
extends Node

var model: Model = null
var self_id: int = 0
var player_count: int = 4
var names: Array[String] = ["Adam", "Barney", "Charles III", "Diana"]

func _ready() -> void:
	if not self.load_last_save():
		self.model = Model.new()
		self.model.build(names)

	EventBus.set_player_view.connect(func(id: int): 
		self.self_id = id
		EventBus.player_view_set.emit(id)
		EventBus.model_loaded.emit()
		EventBus.current_phase_updated.emit(Game.model.get_current_phase())
		EventBus.current_player_updated.emit(Game.model.get_current_player())		
	)

	self.call_deferred("_emit_initial_state")


# func do_bot_action() -> void:
# 	BotBasic.new(Game.model.get_current_player(), self.model).process()


func load_last_save() -> bool:
	var config := ConfigFile.new()
	if config.load("user://settings.cfg") != OK: return false
	
	var filename = config.get_value("settings", "last_save_name")		
	if not FileAccess.file_exists("user://%s.json" % filename): return false
	
	Game.model = ModelLoader.load("user://%s.json" % filename)
	EventBus.model_loaded.emit()
	EventBus.current_phase_updated.emit(Game.model.get_current_phase())
	EventBus.current_player_updated.emit(Game.model.get_current_player())		
	
	return true


func reset() -> void:
	self.model = Model.new()
	self.model.build(names)
	self.call_deferred("_emit_initial_state")


func _emit_initial_state() -> void:
	EventBus.model_loaded.emit()
	EventBus.current_phase_updated.emit(Game.model.get_current_phase())
	EventBus.current_player_updated.emit(Game.model.get_current_player())	
