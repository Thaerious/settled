# filename: python_middleware/listener.gd
class_name Listener
extends RefCounted

signal packet_received(data: Variant)

const NEWLINE_BYTE: int = 10  # "\n"

var _peer: StreamPeerTCP
var _buffer: PackedByteArray = PackedByteArray()  # raw bytes not yet consumed as a complete line
var _reading: bool = false
var _is_running := false


func _init(peer: StreamPeerTCP) -> void:
	self._peer = peer


func listen() -> void:
	if self._is_running: return
	self._is_running = true

	while self._is_running:
		var err := await self.read_response()
		match err:
			OK, ERR_TIMEOUT:
				pass	# packet emitted, or idle
			ERR_PARSE_ERROR:
				pass	# already logged in _parse(); keep listening
			ERR_CONNECTION_ERROR:
				push_error("Listener stopped: server not connected")
				break
			_:
				push_error("Listener stopped: read failed: %s" % error_string(err))
				break

	self._is_running = false


func stop() -> void:
	self._is_running = false


func read_response() -> Error:
	var err: Error = ERR_TIMEOUT  # default if the loop runs out
	var deadline := Time.get_ticks_msec() + int(Client.DEFAULT_TIMEOUT_SEC * Client.MSEC_PER_SEC)

	# multiple call guard (counts against the timeout)
	while self._reading:
		if Time.get_ticks_msec() >= deadline: return err
		await Util.next_frame()

	self._reading = true
	var data: Variant = null  # stays null on timeout, disconnect, or parse error

	while Time.get_ticks_msec() < deadline:
		# consume an already-buffered line first
		var line: Variant = self._take_line()
		if line != null:
			data = self._parse(line)
			err = OK if data != null else ERR_PARSE_ERROR
			break

		self._peer.poll()
		if self._peer.get_status() != StreamPeerTCP.STATUS_CONNECTED:
			err = ERR_CONNECTION_ERROR
			break

		var waiting_bytes := self._peer.get_available_bytes()
		if waiting_bytes > 0:
			var result := self._peer.get_partial_data(waiting_bytes)

			if result[Client.PARTIAL_ERR] != OK:
				err = result[Client.PARTIAL_ERR]
				break

			self._buffer.append_array(result[Client.PARTIAL_BYTES])
			continue  # check the buffer immediately, no frame wait

		await Util.next_frame()

	self._reading = false
	if err == OK: self.packet_received.emit(data)
	return err


# returns the next complete line as a String, or null
func _take_line() -> Variant:
	var index := self._buffer.find(NEWLINE_BYTE)
	if index == Client.NOT_FOUND: return null
	var line := self._buffer.slice(0, index).get_string_from_utf8()
	self._buffer = self._buffer.slice(index + 1)
	return line


func _parse(line: String) -> Variant:
	var json := JSON.new()
	if json.parse(line) != OK:
		push_error("JSON parse error line %s: %s | %s" % [json.get_error_line(), json.get_error_message(), line])
		return null
	return json.data