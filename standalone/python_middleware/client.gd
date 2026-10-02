# filename: python_middleware/client.gd
class_name Client
extends RefCounted


const DEFAULT_TIMEOUT_SEC: float = 5.0
const MSEC_PER_SEC: float = 1000.0
const LINE_DELIMITER: String = "\n"  # newline-delimited JSON framing
const NOT_FOUND: int = -1  # String.find() result when there's no match
const PARTIAL_ERR: int = 0  # get_partial_data() returns [Error, PackedByteArray]
const PARTIAL_BYTES: int = 1
const CONNECT_RETRY_MSEC: int = 100
const CONNECT_TIMEOUT_SEC: float = 10.0


var _port := -1
var _peer: StreamPeerTCP = null

var is_client_connected: bool:
	get(): return self._peer != null and self._peer.get_status() == StreamPeerTCP.STATUS_CONNECTED


func connect_to_server(port: int, ip := "127.0.0.1") -> Array:
	var err := await self._do_connect(port, ip)

	if err != Error.OK:
		push_error("Server connection error | err %s | port %s | ip %s" % [error_string(err), port, ip])
		return [err, null, null]

	return [Error.OK, Writer.new(self._peer), Listener.new(self._peer)]


func _do_connect(port: int, ip: String) -> Error:
	self._port = port
	var deadline := Time.get_ticks_msec() + int(CONNECT_TIMEOUT_SEC * MSEC_PER_SEC)

	while Time.get_ticks_msec() < deadline:
		# create a fresh peer for each attempt. A peer that has failed stays in STATUS_ERROR.
		self._peer = StreamPeerTCP.new()
		
		var err := self._peer.connect_to_host(ip, self._port) 
		if err != OK:
			self._peer = null
			return err

		while self._peer.get_status() == StreamPeerTCP.STATUS_CONNECTING:
			if Time.get_ticks_msec() >= deadline: break
			await Util.next_frame()
			self._peer.poll()

		if self._peer.get_status() == StreamPeerTCP.STATUS_CONNECTED:
			return Error.OK

		# server not listening yet, retry
		await Util.wait(CONNECT_RETRY_MSEC / MSEC_PER_SEC) # don't thrash the port

	self._peer = null
	return Error.ERR_CONNECTION_ERROR





