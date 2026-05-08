class_name StealService
extends Node


func _ready() -> void:
	EventBus.request_steal_from.connect(self.request_steal_from)


func request_steal_from(id: int) -> void:
	var bank := Game.model.get_bank(id)
	var count := Game.model.count_resources(id)
	var i = randi_range(0, count - 1)
	var sum = 0

	for r in Model.ResourceTypes.values():
		sum = sum + bank.get_resource(r)
		if sum > i:
			EventBus.remove_resources.emit(id, Wallet.new([r]))
			EventBus.add_resources.emit(Game.self_id, Wallet.new([r]))
			break

	EventBus.update_phase.emit(Model.GamePhase.MAIN)	