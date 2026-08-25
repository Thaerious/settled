class_name DiscardService
extends Node

func _init() -> void:
	EventBus.request_discard.connect(self._request_discard_hnd)


static func is_pending() -> bool:
	for i in Game.player_count:
		if Game.model.get_bank(i).size() > 7: return true

	return false


func _request_discard_hnd(id:int, discard: Wallet) -> void:
	Game.model.do_remove_resources(id, discard)
	if not DiscardService.is_pending():
		Game.model.do_update_phase.bind(Model.GamePhase.MOVE_PIRATE).call_deferred()
