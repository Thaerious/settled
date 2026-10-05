# filename: routes/bot_route.py
from convert_decision import convert_decision
from convert_model import convert_model
from convert_model import COLORS
from catanatron.models.actions import generate_playable_actions
from catanatron import Game
from routes.debug_discard import debug_discard

def route(server, packet):
	packet_type = packet.get("packet_type", "")

	try:					
		match packet_type:
			case "model":
				game = convert_model(packet.get("data"))
				print(f"received | packet_type: {packet['packet_type']} | player: {COLORS.index(game.state.current_color())} | prompt: {game.state.current_prompt} | discarding: {game.state.is_discarding}")				

				if game.state.is_discarding:
					debug_discard(game)

				bot_decision = decide(game)
				print(f"bot decision {bot_decision}")
				converted = convert_decision(bot_decision, game.state.board.map)
				server.send_packet("decision", converted)		

	except Exception as e:
		print(f"error handling packet | packet_type: '{packet_type}'| error: {e!r}", flush=True)
		server.send_packet("error", {"message": repr(e)})


def decide(game: Game):
	game.state.playable_actions = generate_playable_actions(game.state)
	player = game.state.current_player()
	action = player.decide(game, game.state.playable_actions)
	return action		