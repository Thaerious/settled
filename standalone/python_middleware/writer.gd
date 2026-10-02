# filename: python_middleware/writer.gd
class_name Writer
extends RefCounted

var _peer: StreamPeerTCP


func _init(peer: StreamPeerTCP) -> void:
	self._peer = peer


func send_packet(packet_type: String, data: Variant) -> Error:
	self._peer.poll()
	if self._peer.get_status() != StreamPeerTCP.STATUS_CONNECTED:
		push_error("Send failed: server not connected | packet_type: %s" % packet_type)
		return ERR_CONNECTION_ERROR

	var json_string := JSON.stringify({
		"packet_type": packet_type,
		"data": data
	})

	var err := self._peer.put_data((json_string + Client.LINE_DELIMITER).to_utf8_buffer())
	if err != OK: push_error("Error sending packet: %s" % error_string(err))
	return err