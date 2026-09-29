#!/usr/bin/env python3
# filename: python/BotServer.py
import sys
import json
import socket
from model_converter import convert_model
from bot_runner import decide
from convert_decision import convert_decision

class BotServer:
	def __init__(self, host: str = "127.0.0.1", port: int = 9999, timeout: float = 5):
		self.host = host
		self.port = port
		self.timeout = timeout
		self.server = None
		self.conn = None
		self.reader = None


	def start(self) -> bool:
		# # create a TCP socket
		self.server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

		# # allow immediate re-bind to this port after restart (otherwise the OS
		# # holds the port in TIME_WAIT for a while after the process exits)
		self.server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

		self.server.bind((self.host, self.port))
		self.server.listen(1)  # backlog of 1 — we only expect Godot as a single client
		self.server.settimeout(self.timeout)

		print("server ready", flush=True)

		# # block here until Godot connects
		try:
			self.conn, _ = self.server.accept()
		except socket.timeout:
			print("no connection within timeout", flush=True)
			return False

		self.conn.settimeout(None)

		# # wrap the raw socket in a buffered, line-oriented file object —
		# # readline yields one line per b"\n"
		self.reader = self.conn.makefile("rb")
		return True


	def receive_packet(self) -> dict | None:
		line = self.reader.readline()
		if not line: return None # b"" means EOF			
		decoded_packet = json.loads(line)
		return decoded_packet


	def send_packet(self, action: str, data: dict | None = None) -> None:
			packet = {
				"action_type": action,
				"data": data if data is not None else {}
			}
			print(f"Send Packet: {packet}", flush=True)
			self.conn.sendall((json.dumps(packet, default=str) + "\n").encode())


	def run(self) -> None:
		action = ""
		try:
			while action != "exit":
				packet = self.receive_packet()
				if packet is None: break
				action = packet.get("action", "")

				try:					
					match action:
						case "model":
							game = convert_model(packet.get("data"))
							bot_decision = decide(game)
							converted = convert_decision(bot_decision, game.state.board.map)
							self.send_packet("decision", converted)
						case "exit":
							self.send_packet("exit")
						case _:
							self.send_packet("error", {"message": f"unknown action: {action}"})
				except Exception as e:
					print(f"error handling '{action}': {e!r}", flush=True)
					self.send_packet("error", {"message": repr(e)})
		except (ConnectionResetError, ConnectionAbortedError, BrokenPipeError):
			print("client dropped", flush=True)
		finally:
			self.close()


	def close(self) -> None:
		for resource in (self.reader, self.conn, self.server):
			if resource is not None:
				resource.close()


if __name__ == "__main__":
	bot_server = BotServer()
	print("Starting server", flush=True)
	if not bot_server.start():
		print("Server failed to start", flush=True)
		bot_server.close()
		sys.exit(1)

	print("Server running", flush=True)
	bot_server.run()