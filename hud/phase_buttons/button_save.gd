extends Button

@onready var _file_name_tb:LineEdit = %SaveFileName

func _pressed():
	var filename = self._file_name_tb.text

	ModelLoader.save(Game.model, "user://%s.json" % filename)

	var config := ConfigFile.new()
	config.set_value("settings", "last_save_name", filename)
	config.save("user://settings.cfg")
