#!/usr/bin/env python3
# filename: python/ServerInstance.py
import json
import socket
from typing import Callable


class ServerInstance:
	def __init__(self, conn: socket.socket, routes: list[Callable], on_close: Callable | None = None):
		self.conn = conn
		self.conn.settimeout(None)  # instance thread is a daemon, blocking is fine
		self.reader = conn.makefile("rb")  # readline yields one line per b"\n"
		self.routes = routes
		self.on_close = on_close
		self._closed = False


	def receive_packet(self) -> dict | None:
		line = self.reader.readline()
		if not line: return None  # b"" means EOF
		return json.loads(line)


	def send_packet(self, packet_type: str, data: dict | None = None) -> None:
		packet = {
			"packet_type": packet_type,
			"data": data if data is not None else {}
		}
		print(f"Send Packet: {packet}")
		self.conn.sendall((json.dumps(packet, default=str) + "\n").encode())


	def run(self) -> None:
		try:
			while True:
				packet = self.receive_packet()
				if packet is None: break
				print(f"Packet Received {packet['packet_type']}")

				for route in self.routes:
					route(self, packet)

				if packet.get("packet_type", "") == "exit":
					self.send_packet("exit")
					break

		except (ConnectionResetError, ConnectionAbortedError, BrokenPipeError, OSError):
			print("client dropped")
		finally:
			self.close()


	def close(self) -> None:
		if self._closed: return
		self._closed = True

		try:
			self.conn.shutdown(socket.SHUT_RDWR)  # unblocks readline() in the instance thread
		except OSError:
			pass

		self.reader.close()
		self.conn.close()

		if self.on_close is not None:
			self.on_close(self)