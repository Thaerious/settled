## event_bus_logger.gd
class_name EventBusLogger
extends Node

@export var mute := false

func event_print(msg: String):
	if mute: return
	print(msg)

func _ready() -> void:
	EventBus.show_house_targets.connect(func():event_print("EventBus.show_house_targets"))
	EventBus.show_city_targets.connect(func():event_print("EventBus.show_city_targets"))
	EventBus.show_road_targets.connect(func():event_print("EventBus.show_road_targets"))
	EventBus.clear_targets.connect(func():event_print("EventBus.clear_targets"))

	EventBus.request_roll.connect(func():event_print("EventBus.request_roll"))
	EventBus.request_purchase_action_card.connect(func(id: int):event_print("EventBus.request_purchase_action_card | id: %s" % [id]))
	EventBus.request_play_action_card.connect(func(id: int, card: Model.ActionCardTypes):event_print("EventBus.request_play_action_card | id: %s | card: %s" % [id, Model.ActionCardTypes.find_key(card)]))
	EventBus.request_house.connect(func(id: int, corner: Axial):event_print("EventBus.request_house | id: %s | corner: %s" % [id, corner]))
	EventBus.request_city.connect(func(id: int, corner: Axial):event_print("EventBus.request_city | id: %s | corner: %s" % [id, corner]))
	EventBus.request_road.connect(func(id: int, edge: AxialEdge):event_print("EventBus.request_road | id: %s | edge: %s" % [id, edge]))
	EventBus.request_exchange.connect(func(id: int, from: Model.ResourceTypes, to: Model.ResourceTypes):event_print("EventBus.request_exchange | id: %s | from: %s | to: %s" % [id, Model.ResourceTypes.find_key(from), Model.ResourceTypes.find_key(to)]))
	EventBus.request_set_pirate.connect(func(id: int, hex: Axial):event_print("EventBus.request_set_pirate | id: %s | hex: %s" % [id, hex]))
	EventBus.request_steal_from.connect(func(id: int):event_print("EventBus.request_steal_from | id: %s" % [id]))
	EventBus.request_add_action_card.connect(func(id: int, c: Model.ActionCardTypes):event_print("EventBus.request_add_action_card | id: %s | c: %s" % [id, Model.ActionCardTypes.find_key(c)]))
	EventBus.request_discard.connect(func(id: int, discard: Wallet):event_print("EventBus.request_discard | id: %s | discard: %s" % [id, discard]))
	EventBus.play_monopoly_card.connect(func(id: int, resource: Model.ResourceTypes):event_print("EventBus.play_monopoly_card | id: %s | resource: %s" % [id, Model.ResourceTypes.find_key(resource)]))
	EventBus.play_plenty_card.connect(func(id: int, resources: Wallet):event_print("EventBus.play_plenty_card | id: %s | resources: %s" % [id, resources]))
	EventBus.play_road_building_card.connect(func(id: int, roads: AxialEdgeSet):event_print("EventBus._play_road_building_card | id: %s | roads: %s" % [id, roads]))
	EventBus.notify.connect(func(id: int, msg: String):event_print("EventBus.notify | id: %s | msg: %s" % [id, msg]))
	EventBus.info.connect(func(id: int, msg: String):event_print("EventBus.message | id: %s | msg: %s" % [id, msg]))
	EventBus.model_loaded.connect(func():event_print("EventBus.model_loaded"))
	EventBus.pirate_set.connect(func(hex: Axial):event_print("EventBus.pirate_set | hex: %s" % [hex]))
	EventBus.exchange_rate_set.connect(func(id: int, wallet: Wallet):event_print("EventBus.exchange_rate_set | id: %s | wallet: %s " % [id, wallet]))
	EventBus.current_player_updated.connect(func(current_player: int):event_print("EventBus.current_player_updated | current_player: %s" % [current_player]))
	EventBus.current_phase_updated.connect(func(phase: Model.GamePhase):event_print("EventBus.current_phase_updated | phase: %s" % [Model.GamePhase.find_key(phase)]))
	EventBus.action_cards_updated.connect(func(id: int, owned: ActionCardWallet, playable: ActionCardWallet):event_print("EventBus.action_cards_updated | id: %s | owned: %s | playable: %s" % [id, owned, playable]))
	EventBus.house_added.connect(func(id: int, corner: Axial):event_print("EventBus.house_added | id: %s | corner: %s" % [id, corner]))
	EventBus.city_added.connect(func(id: int, corner: Axial):event_print("EventBus.city_added | id: %s | corner: %s" % [id, corner]))
	EventBus.road_added.connect(func(id: int, edge: AxialEdge):event_print("EventBus.road_added | id: %s | edge: %s" % [id, edge]))
	EventBus.dice_set.connect(func(d1: int, d2: int):event_print("EventBus.dice_set | d1: %s | d2: %s" % [d1, d2]))
	EventBus.player_record_updated.connect(func(record: PlayerRecord):event_print("EventBus.player_record_updated | %s" % [record]))
	EventBus.resources_updated.connect(func(id: int, wallet: Wallet):event_print("EventBus.resources_updated | id: %s | wallet: %s" % [id, wallet]))
	EventBus.resources_received.connect(func(id: int, wallet: Wallet):event_print("EventBus.resources_received | id: %s | wallet: %s" % [id, wallet]))
	EventBus.set_player_view.connect(func(id: int):event_print("EventBus.set_player_view | id: %s" % [id]))
	EventBus.error.connect(func(msg: String):event_print("EventBus.error | msg: %s" % [msg]))
	
