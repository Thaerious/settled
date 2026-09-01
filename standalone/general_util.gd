class_name GeneralUtil

static var _last_message = null

static func print_once(string: String) -> void:
	if GeneralUtil._last_message == string: return
	print(string)
	GeneralUtil._last_message = string