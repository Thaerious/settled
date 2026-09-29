# filename: python/convert_decision.py
from catanatron.models.player import Color
from catanatron.models.enums import ActionType
from AxialTable import AxialTable
from model_converter import COLORS

def convert_decision(action, catan_map) -> dict:
	axial_table = AxialTable(catan_map)
	v = action.value
	data = None

	match action.action_type:
		case ActionType.BUILD_ROAD:
			data = axial_table.from_edge(v)

		case ActionType.BUILD_SETTLEMENT | ActionType.BUILD_CITY:
			data = axial_table.from_corner(v)

		case ActionType.MOVE_ROBBER:
			data = {
				"hex": axial_table.from_hex(v[0]),
				"victim": COLORS.index(v[1]) if v[1] is not None else -1
			}

		case ActionType.DISCARD:
			data = list(v) if v is not None else []

		case ActionType.PLAY_YEAR_OF_PLENTY:
			data = list(v)

		case ActionType.PLAY_MONOPOLY:
			data = v

		case ActionType.MARITIME_TRADE:
			data = {
				"give": [r for r in v[:4] if r is not None],
				"get": v[4]
			}

		# ROLL, BUY_DEVELOPMENT_CARD, PLAY_KNIGHT_CARD, PLAY_ROAD_BUILDING, END_TURN -> None

	return {
		"action": action.action_type.value,
		"data": data,
		"pid": COLORS.index(action.color)
	}


