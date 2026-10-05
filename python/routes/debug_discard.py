# filename: python/debug_discard.py
import inspect
from catanatron import Game
from catanatron.models import actions
from catanatron.models.enums import ActionType
from catanatron.state_functions import player_num_resource_cards

def debug_discard(game: Game):
	color = game.state.current_color()

	# 1. Does this version use DISCARD or DISCARD_RESOURCE?
	print("action types:", [a.name for a in ActionType])

	# 2. The actual code that builds discard options (shows what it checks)
	print(inspect.getsource(actions.discard_possibilities))

	# 3. How many cards the discarder has in the rebuilt state
	print("hand:", player_num_resource_cards(game.state, color))

	# 4. Every state field with "discard" in its name, and its value
	print("discard fields:", {k: v for k, v in vars(game.state).items() if "discard" in k})