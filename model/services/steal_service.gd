class_name StealService
extends Node


func _ready() -> void:
	EventBus.request_steal_from.connect(self.request_steal_from)


func request_steal_from(to: int, from: int) -> void:
	var bank := Game.model.get_bank(from)
	var count := Game.model.count_resources(from)
	var i = randi_range(0, count - 1)
	var sum = 0
	var resource_name = ""

	assert (bank.sum() > 0)
	
	for r in Model.ResourceTypes.values():
		sum = sum + bank.get_resource(r)
		if sum > i:
			Game.model.do_remove_resources(from, Wallet.new([r]))
			Game.model.do_add_resources(to, Wallet.new([r]))
			resource_name = Model.ResourceTypes.find_key(r)
			break

	var from_name = Game.model.get_player_record(from).name
	var to_name = Game.model.get_player_record(to).name
	
	for pid in Game.model.player_count():	
		if pid == to:
			EventBus.info.emit(pid, "You stole %s from %s" % [resource_name, from_name])
		else:
			EventBus.info.emit(pid, "%s stole from %s" % [to_name, from_name])

	Game.model.do_update_phase(Model.GamePhase.MAIN)
