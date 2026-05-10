class_name StealService
extends Node


func _ready() -> void:
	EventBus.request_steal_from.connect(self.request_steal_from)


func request_steal_from(id: int) -> void:
	print("Steal Service")
	var bank := Game.model.get_bank(id)
	var count := Game.model.count_resources(id)
	var i = randi_range(0, count - 1)
	var sum = 0

	for r in Model.ResourceTypes.values():
		sum = sum + bank.get_resource(r)
		if sum > i:
			Game.model.do_remove_resources(id, Wallet.new([r]))
			Game.model.do_add_resources(Game.self_id, Wallet.new([r]))
			break

	Game.model.do_update_phase(Model.GamePhase.MAIN)
