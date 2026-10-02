# filename: python_middleware/server.gd
class_name Server
extends RefCounted


var _pid := -1
var _stdio: FileAccess = null
var _stderr: FileAccess = null

var _port := -1
var port : int = -1:
	get(): return self._port

var is_server_launched: bool:
	get(): return self._stdio != null


func launch_server(port: int) -> bool:	
	self._port = port
	var exe_path := ProjectSettings.globalize_path("res://python/venv/Scripts/python.exe")
	var script_path := ProjectSettings.globalize_path("res://python/SettledServer.py")
	var result := OS.execute_with_pipe(exe_path, [script_path, "--port", str(port)], false)

	# var exe_path := ProjectSettings.globalize_path("res://python/dist/server/server.exe")
	# var result := OS.execute_with_pipe(exe_path, [])

	if result.is_empty():
		push_error("Server failed to launch")
		return false

	self._pid = result["pid"]
	self._stdio = result["stdio"]
	self._stderr = result["stderr"]	

	Engine.get_main_loop().process_frame.connect(self.read_stdout)

	return true


func read_stdout() -> void:
	if not self.is_launched: return

	while not self._stdio.eof_reached():
		var line = self._stdio.get_line()
		if line == "": break
		print("[python] %s" % line)

	if self._stderr == null: return
	while not self._stderr.eof_reached():
		var line = self._stderr.get_line()
		if line == "": break
		print("[error] %s" % line)	