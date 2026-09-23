extends Node2D

var _pid := -1
var _stdio: FileAccess = null
var _port := -1
var _peer: StreamPeerTCP = null
var _recv_buffer: PackedByteArray = PackedByteArray()
var _launch_thread: Thread
var _is_ready := false


func _process(_1: float) -> void:
	if self._stdio == null: return
	
	while not self._stdio.eof_reached():
		var line = self._stdio.get_line()
		if line == "": break
		print("[python] %s" % line)


func launch_server(_port: int) -> bool:
	print("launch_server")
	self._port = _port

	if _stdio != null:
		print("Warning: Python server already started")
		return false

	_launch_thread = Thread.new()
	print("do_launch")
	_launch_thread.start(_do_launch)
	print("return true")
	return true


func _do_launch() -> void:	
	var exe_path := "python"
	var result := OS.execute_with_pipe(exe_path, ["D:/trunk/godot/settled/python/server.py"], false)

	# var exe_path := ProjectSettings.globalize_path("res://python/dist/server/server.exe")
	# var result := OS.execute_with_pipe(exe_path, [])	

	if result.is_empty():
		print("Error: Server failed to launch")
		return

	self._pid = result["pid"]
	self._stdio = result["stdio"]
	print("_connect_to_server")
	self._connect_to_server()
	print("connected to server")


func _connect_to_server() -> void:
	self._peer = StreamPeerTCP.new()
	self._peer.connect_to_host("127.0.0.1", 9999)
	
	# wait for connection to establish
	while self._peer.get_status() == StreamPeerTCP.STATUS_CONNECTING:
		self._peer.poll()
		OS.delay_msec(10)

	if self._peer.get_status() != StreamPeerTCP.STATUS_CONNECTED:
		print("Error: failed to connect, status = %s" % self._peer.get_status())
		self._peer = null
		return
	
	self._is_ready = true


func send_model(model: Model) -> void:
	while not self._is_ready:
		OS.delay_msec(10)

	if self._peer == null:
		print("Python not connected")
		return

	print("Sending Model")
	var data = ModelLoader.encode(model)
	var json_string := JSON.stringify(data)
	var err := self._peer.put_data((json_string + "\n").to_utf8_buffer())
	if err != OK:
		print("Error sending model: %s" % err)
	else:
		print("Model Sent")


func read_response() -> String:
	var response = ""
	if self._peer == null: return ""

	self._peer.poll()
	var available = self._peer.get_available_bytes()
	if available > 0:
		self._recv_buffer.append_array(self._peer.get_data(available)[1])

	while true:
		var nl_index := self._recv_buffer.find(10)  # 10 == "\n"
		if nl_index == -1: break

		var line_bytes := self._recv_buffer.slice(0, nl_index)
		self._recv_buffer = self._recv_buffer.slice(nl_index)

		response = response +  line_bytes.get_string_from_utf8()

	return response
