# filename: routes/bot_route.py
from convert_decision import convert_decision
from convert_model import convert_model
from bot_runner import decide


def route(server, packet):
	print("Running bot route")
	packet_type = packet.get("packet_type", "")

	try:					
		match packet_type:
			case "model":
				game = convert_model(packet.get("data"))
				bot_decision = decide(game)
				converted = convert_decision(bot_decision, game.state.board.map)
				server.send_packet("decision", converted)			
	except Exception as e:
		print(f"error handling '{packet_type}': {e!r}", flush=True)
		server.send_packet("error", {"message": repr(e)})