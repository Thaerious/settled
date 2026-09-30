#!/usr/bin/env python3
# filename: python/Server.py
import sys
import socket
import argparse
import threading
import importlib.util
import traceback
from pathlib import Path

from ServerInstance import ServerInstance


class Server:
	ACCEPT_TIMEOUT = 0.5  # short accept timeout so Ctrl+C is serviced on Windows

	def __init__(self, host: str = "127.0.0.1", port: int = 9999, timeout: float = -1):
		self.host = host
		self.port = port
		self.timeout = timeout  # seconds to wait for the FIRST connection, -1 = forever
		self.server = None
		self.routes = []
		self.instances: list[ServerInstance] = []


	def load_routes(self, routes_dir: str) -> None:
		# TODO: PyInstaller — loose routes/*.py aren't bundled. Ship routes/ next to the exe and
		#       resolve base from sys.executable when frozen:
		#       base = Path(sys.executable).parent if getattr(sys, "frozen", False) else Path(__file__).parent
		path = Path(routes_dir)

		if not path.is_absolute():
			path = Path(__file__).parent / path  # resolve relative to Server.py, not the cwd

		if not path.is_dir():
			print(f"routes dir not found: {path}")
			return

		for file in sorted(path.glob("*.py")):
			if file.name.startswith("_"): continue  # skip __init__.py and private helpers

			spec = importlib.util.spec_from_file_location(f"routes.{file.stem}", file)
			module = importlib.util.module_from_spec(spec)

			try:
				spec.loader.exec_module(module)				
			except Exception as e:
				print(f"failed to load route {file.name}:")
				traceback.print_exc()
				continue		

			route = getattr(module, "route", None)
			if callable(route):
				self.routes.append(route)
				print(f"loaded route: {file.stem}")


	def start(self) -> bool:
		try:
			self.server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
			if sys.platform == "win32":
				self.server.setsockopt(socket.SOL_SOCKET, socket.SO_EXCLUSIVEADDRUSE, 1)  # SO_REUSEADDR on Windows allows duplicate binds
			else:
				self.server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)  # skip TIME_WAIT on restart
			self.server.bind((self.host, self.port))
			self.server.listen()
			self.server.settimeout(self.ACCEPT_TIMEOUT)
		except OSError as e:
			print(f"bind failed on {self.host}:{self.port}: {e}")
			return False

		print("server ready")
		return True


	def await_connection(self) -> ServerInstance | None:
		waited = 0.0
		while self.timeout <= -1 or self.instances or waited < self.timeout:
			try:
				conn, addr = self.server.accept()
			except socket.timeout:
				waited += self.ACCEPT_TIMEOUT
				continue

			print(f"Client Connected: {addr}")
			instance = ServerInstance(conn, self.routes, on_close=self._on_instance_closed)
			self.instances.append(instance)
			threading.Thread(target=instance.run, daemon=True).start()
			return instance

		print("no connection within timeout")
		return None


	def serve(self) -> None:
		print("Awaiting Connections")
		try:
			while self.await_connection() is not None:
				pass
		except KeyboardInterrupt:
			print("interrupted")
		finally:
			self.close()


	def _on_instance_closed(self, instance: ServerInstance) -> None:
		if instance in self.instances:
			self.instances.remove(instance)


	def close(self) -> None:
		for instance in list(self.instances):
			instance.close()
		if self.server is not None:
			self.server.close()
			self.server = None


if __name__ == "__main__":
	sys.stdout.reconfigure(line_buffering=True)

	parser = argparse.ArgumentParser(description="Settled bot server")
	parser.add_argument("--host", default="127.0.0.1", help="bind address (default: 127.0.0.1)")
	parser.add_argument("--port", type=int, default=9999, help="bind port (default: 9999)")
	parser.add_argument("--timeout", type=float, default=-1, help="seconds to wait for first connection, -1 = forever (default: -1)")
	parser.add_argument("--routes", default="routes", help="routes directory, relative to Server.py (default: routes)")	
	args = parser.parse_args()

	bot_server = Server(host=args.host, port=args.port, timeout=args.timeout)
	bot_server.load_routes(args.routes)
	print(f"Starting server on {args.host}:{args.port}")

	if not bot_server.start():
		bot_server.close()
		sys.exit(1)

	bot_server.serve()