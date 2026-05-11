extends Button

@onready var _file_name_tb:LineEdit = %SaveFileName

func _pressed():
	var filename = self._file_name_tb.text
	Game.model.load("user://%s.json" % filename)
	EventBus.model_loaded.emit()