# filename: standalone/util.gd
class_name Util

static var _last_message = null


static func print_once(string: String) -> void:
	if Util._last_message == string: return
	print(string)
	Util._last_message = string


static func next_frame() -> void:
	await (Engine.get_main_loop() as SceneTree).process_frame	


static func wait(seconds: float) -> void:
	await (Engine.get_main_loop() as SceneTree).create_timer(seconds).timeout	