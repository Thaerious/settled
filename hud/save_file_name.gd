extends LineEdit

@onready var _file_name_tb:LineEdit = %SaveFileName

# Called when the node enters the scene tree for the first time.
func _ready():
	var config := ConfigFile.new()
	config.load("user://settings.cfg")
	var filename = config.get_value("settings", "last_save_name", "default")
	self._file_name_tb.text = filename
