extends Node2D

var _pid: int = -1
var _stdio = null

func launch_server(_port: int) -> bool:
	if _stdio != null: 
		print("[python] Python server already started")
		return false

	var exe_path := ProjectSettings.globalize_path("res://python/dist/server/server.exe")
	var result := OS.execute_with_pipe(exe_path, [])	
	if result.is_empty(): return false

	self._pid = result["pid"]
	self._stdio = result["stdio"]
	return true


func _process(_delta: float) -> void:
	if self._stdio == null: return
	
	while not self._stdio.eof_reached():
		var line = self._stdio.get_line()
		if line == "": break
		print("[python] %s" % line)
