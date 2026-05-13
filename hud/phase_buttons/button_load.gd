extends Button

@onready var _file_name_tb:LineEdit = %SaveFileName

func _pressed():
	var filename = self._file_name_tb.text
	Game.model.load("user://%s.json" % filename)
	EventBus.model_loaded.emit()

	var config := ConfigFile.new()
	config.set_value("settings", "last_save_name", filename)
	config.save("user://settings.cfg")