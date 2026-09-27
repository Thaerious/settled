extends Node2D

const DEFAULT_TIMEOUT_SEC: float = 5.0
const MSEC_PER_SEC: float = 1000.0
const LINE_DELIMITER: String = "\n"  # newline-delimited JSON framing
const NOT_FOUND: int = -1  # String.find() result when there's no match
const PARTIAL_ERR: int = 0  # get_partial_data() returns [Error, PackedByteArray]
const PARTIAL_BYTES: int = 1

var _pid := -1
var _stdio: FileAccess = null
var _stderr: FileAccess = null
var _port := -1
var _peer: StreamPeerTCP = null
var _buffer: String = ""  # received text not yet consumed as a complete line
var _launch_thread: Thread
var _is_ready := false
var _reading: bool = false

func _process(_1: float) -> void:
	if self._stdio == null: return
	
	while not self._stdio.eof_reached():
		var line = self._stdio.get_line()
		if line == "": break
		print("[python] %s" % line)

	if self._stderr == null: return
	while not self._stderr.eof_reached():
		var line = self._stderr.get_line()
		if line == "": break
		print("[error] %s" % line)		


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
	var exe_path := ProjectSettings.globalize_path("res://python/venv/Scripts/python.exe")
	var result := OS.execute_with_pipe(exe_path, ["D:/trunk/godot/settled/python/BotServer.py"], false)

	# var exe_path := ProjectSettings.globalize_path("res://python/dist/server/server.exe")
	# var result := OS.execute_with_pipe(exe_path, [])	

	if result.is_empty():
		print("Error: Server failed to launch")
		return

	self._pid = result["pid"]
	self._stdio = result["stdio"]
	self._stderr = result["stderr"]
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


func read_response(cb: Callable = Callable(), timeout_sec: float = DEFAULT_TIMEOUT_SEC) -> Variant:
	# multiple call guard
	while self._reading: await self.get_tree().process_frame
	self._reading = true

	var data: Variant = null  # stays null on timeout or disconnect
	var deadline := Time.get_ticks_msec() + int(timeout_sec * MSEC_PER_SEC)

	while Time.get_ticks_msec() < deadline:
		self._peer.poll()
		if self._peer.get_status() != StreamPeerTCP.STATUS_CONNECTED: break
		
		var n = self._peer.get_available_bytes()
		if n > 0:
			var result := self._peer.get_partial_data(n)
			if result[PARTIAL_ERR] == OK:
				self._buffer += (result[PARTIAL_BYTES] as PackedByteArray).get_string_from_utf8()

		var delimiter_index := self._buffer.find(LINE_DELIMITER)

		if delimiter_index != NOT_FOUND:
			var line := self._buffer.substr(0, delimiter_index)
			self._buffer = self._buffer.substr(delimiter_index + LINE_DELIMITER.length())  # skip past the delimiter
			data = JSON.parse_string(line)
			break

		await self.get_tree().process_frame

	self._reading = false
	if cb.is_valid(): cb.call(data)  # will be null on timeout or disconnected

	return data


func send_packet(action, data) -> void:
	var timeout = 0

	if self._peer == null:
		print("Python not connected")
		return	
	
	while not self._is_ready:
		OS.delay_msec(10)
		timeout += 1
		if timeout >= 100:
			print("Error: Timeout sending packet")
			return

	var json_string := JSON.stringify({
		"action": action,
		"data": data
	})		

	var err := self._peer.put_data((json_string + "\n").to_utf8_buffer())
	
	if err != OK:
		print("Error sending model: %s" % err)
	else:
		print("Model Sent")	