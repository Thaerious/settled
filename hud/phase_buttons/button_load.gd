extends Button

@onready var _file_name_tb:LineEdit = %SaveFileName

func _pressed():
	var filename = self._file_name_tb.text
	Game.model = ModelLoader.load("user://%s.json" % filename)
	EventBus.model_loaded.emit()
	EventBus.current_phase_updated.emit(Game.model.get_current_phase())
	EventBus.current_player_updated.emit(Game.model.get_current_player())	

	var config := ConfigFile.new()
	config.set_value("settings", "last_save_name", filename)
	config.save("user://settings.cfg")
