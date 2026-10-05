# filename: python/convert_decision.py
from catanatron.models.player import Color
from catanatron.models.enums import ActionType
from AxialTable import AxialTable
from convert_model import COLORS

def convert_decision(action, catan_map) -> dict:
	axial_table = AxialTable(catan_map)
	action_value = action.value

	packet = {
		"action": action.action_type.value,
		"pid": COLORS.index(action.color)
	}

	match action.action_type:
		case ActionType.BUILD_ROAD:
			packet["edge"] = axial_table.from_edge(action_value)

		case ActionType.BUILD_SETTLEMENT | ActionType.BUILD_CITY:
			packet["corner"] = axial_table.from_corner(action_value)

		case ActionType.MOVE_ROBBER:
			packet["hex"] = axial_table.from_hex(action_value[0])
			packet["victim"] = COLORS.index(action_value[1]) if action_value[1] is not None else -1

		case ActionType.DISCARD_RESOURCE:
			packet["resources"] = action_value

		case ActionType.PLAY_YEAR_OF_PLENTY:
			packet["resources"] = list(action_value)

		case ActionType.PLAY_MONOPOLY:
			packet["resources"] = action_value

		case ActionType.MARITIME_TRADE:
			packet["give"] = [r for r in action_value[:4] if r is not None]
			packet["get"] = action_value[4]

		# ROLL, BUY_DEVELOPMENT_CARD, PLAY_KNIGHT_CARD, PLAY_ROAD_BUILDING, END_TURN -> None

	return packet