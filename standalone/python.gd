# filename: standalone/python.gd
extends Node2D

signal server_connected()

const DEFAULT_TIMEOUT_SEC: float = 5.0
const MSEC_PER_SEC: float = 1000.0
const LINE_DELIMITER: String = "\n"  # newline-delimited JSON framing
const NOT_FOUND: int = -1  # String.find() result when there's no match
const PARTIAL_ERR: int = 0  # get_partial_data() returns [Error, PackedByteArray]
const PARTIAL_BYTES: int = 1
const CONNECT_RETRY_MSEC: int = 100
const CONNECT_TIMEOUT_SEC: float = 10.0

var _pid := -1
var _stdio: FileAccess = null
var _stderr: FileAccess = null
var _port := -1
var _peer: StreamPeerTCP = null
var _buffer: String = ""  # received text not yet consumed as a complete line
var _is_ready := false
var _reading: bool = false

var is_launched: bool:
	get(): return self._stdio != null


func _process(_1: float) -> void:
	self.read_stdout()	


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


func launch_server(_port: int) -> bool:	
	if self.is_launched: return false
	self._port = _port

	var exe_path := ProjectSettings.globalize_path("res://python/venv/Scripts/python.exe")
	var result := OS.execute_with_pipe(exe_path, ["D:/trunk/godot/settled/python/BotServer.py"], false)

	# var exe_path := ProjectSettings.globalize_path("res://python/dist/server/server.exe")
	# var result := OS.execute_with_pipe(exe_path, [])

	if result.is_empty():
		push_error("Server failed to launch")
		return false

	self._pid = result["pid"]
	self._stdio = result["stdio"]
	self._stderr = result["stderr"]
	return await self._connect_to_server()


func _connect_to_server() -> bool:
	var deadline := Time.get_ticks_msec() + int(CONNECT_TIMEOUT_SEC * MSEC_PER_SEC)

	while Time.get_ticks_msec() < deadline:
		self._peer = StreamPeerTCP.new()
		self._peer.connect_to_host("127.0.0.1", self._port) # creates a fresh peer for each attempt. A peer that has failed stays in STATUS_ERROR.

		while self._peer.get_status() == StreamPeerTCP.STATUS_CONNECTING:
			await self.get_tree().process_frame
			self._peer.poll()

		if self._peer.get_status() == StreamPeerTCP.STATUS_CONNECTED:
			self._is_ready = true
			self.server_connected.emit()
			self.read_stdout()
			return true

		# server not listening yet, retry
		await self.get_tree().create_timer(CONNECT_RETRY_MSEC / MSEC_PER_SEC).timeout # don't thrash the port

	push_error("Failed to connect to server on port %s" % self._port)
	self._peer = null
	self.read_stdout()
	return false


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
	print("Python.send_packet(%s, ...)" % action)

	if not self.is_launched:
		push_error("Server not started")
		return

	if not self._is_ready:
		await self.server_connected

	var json_string := JSON.stringify({
		"action": action,
		"data": data
	})

	var err := self._peer.put_data((json_string + LINE_DELIMITER).to_utf8_buffer())
	if err != OK: push_error("Error sending packet: %s" % err)

	self.read_stdout()
	print("packet sent")
