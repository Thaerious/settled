from catanatron.game import Game # type: ignore
from catanatron.models.actions import generate_playable_actions # type: ignore


def decide(game: Game):
	game.state.playable_actions = generate_playable_actions(game.state)
	player = game.state.current_player()
	action = player.decide(game, game.state.playable_actions)
	print(f"Action: {action}", flush=True)
	return action
