#!/usr/bin/env python3
import socket

print("Initiating Server...", flush = True)

HOST = "127.0.0.1"
PORT = 9999

# # create a TCP socket
server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# # allow immediate re-bind to this port after restart (otherwise the OS
# # holds the port in TIME_WAIT for a while after the process exits)
server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

server.bind((HOST, PORT))
server.listen(1)  # backlog of 1 — we only expect Godot as a single client
server.settimeout(5)

# # block here until Godot connects
try:
	conn, addr = server.accept()
except socket.timeout:
	print("no connection within timeout", flush=True)


# # wrap the raw socket in a buffered, line-oriented file object —
# # iterating it yields one line per b"\n"
reader = conn.makefile("rb")

print("Server Ready", flush=True)
# # blocks on each iteration until a full line has arrived
for line in reader:
	line = line.strip()
	if not line: continue  # skip stray blank lines

	# line is the raw JSON bytes for one request
	print(line, flush=True)

	# newline-terminated response, same framing as the request
	conn.sendall(b'{"status":"ok"}\n')