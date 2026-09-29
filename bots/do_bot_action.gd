# filename: bots/do_bot_action.gd
class_name DoBotAction
extends RefCounted

const RESOURCE_NAMES := {
	"WOOD":		Model.ResourceTypes.WOOD,
	"BRICK":	Model.ResourceTypes.BRICK,
	"WHEAT":	Model.ResourceTypes.WHEAT,
	"SHEEP":	Model.ResourceTypes.WOOL,
	"ORE":		Model.ResourceTypes.ROCK,
}

static var _free_roads := AxialEdgeSet.new()	# road building buffer


static func run(packet: Dictionary) -> void:
	print("DoBotAction.run(%s)" % packet)

	var pid: int = packet["pid"]
	var data = packet["data"]

	match packet["action"]:
		"ROLL":
			EventBus.request_roll.emit()

		"BUILD_SETTLEMENT":
			EventBus.request_house.emit(pid, Axial.from_key(data))

		"BUILD_CITY":
			EventBus.request_city.emit(pid, Axial.from_key(data))

		"BUILD_ROAD":
			var edge = AxialEdge.from_key(data)
			if Game.model.get_current_phase() == Model.GamePhase.ROAD_BUILDING:
				_free_roads.add(edge)
				if _free_roads.size() >= 2:
					EventBus.play_road_building_card.emit(pid, _free_roads)
					_free_roads = AxialEdgeSet.new()
			else:
				EventBus.request_road.emit(pid, edge)

		"MOVE_ROBBER":
			EventBus.request_set_pirate.emit(pid, Axial.from_key(data["hex"]))
			var victim: int = data["victim"]
			if victim != -1: EventBus.request_steal_from.emit(pid, victim)

		"DISCARD":
			EventBus.request_discard.emit(pid, to_wallet(data))	# ?

		"BUY_DEVELOPMENT_CARD":
			EventBus.request_purchase_action_card.emit(pid)

		"PLAY_KNIGHT_CARD":
			EventBus.request_play_action_card.emit(pid, Model.ActionCardTypes.SOLDIER)

		"PLAY_ROAD_BUILDING":
			_free_roads = AxialEdgeSet.new()
			EventBus.request_play_action_card.emit(pid, Model.ActionCardTypes.BUILD_ROAD)

		"PLAY_YEAR_OF_PLENTY":
			EventBus.request_play_action_card.emit(pid, Model.ActionCardTypes.PLENTY)
			EventBus.plenty_card_decision.emit(pid, to_wallet(data))	# ?

		"PLAY_MONOPOLY":
			EventBus.request_play_action_card.emit(pid, Model.ActionCardTypes.MONOPOLY)
			EventBus.monopoly_card_decision.emit(pid, to_resource(data))	# ?

		"MARITIME_TRADE":
			EventBus.request_exchange.emit(pid, to_resource(data["give"][0]), to_resource(data["get"]))

		"END_TURN":
			EventBus.request_end_turn.emit()

		_:
			push_error("DoBotAction: unhandled action %s" % packet["action"])


static func to_resource(name: String) -> Model.ResourceTypes:
	return RESOURCE_NAMES[name]


static func to_wallet(names: Array) -> Wallet:
	var types: Array = []
	for n in names:
		types.append(to_resource(n))
	return Wallet.new(types)