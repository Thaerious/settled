class_name ActionCardWallet
extends RefCounted


var _data: Dictionary[Model.ActionCardTypes, int] = {
	Model.ActionCardTypes.SOLDIER: 0,
	Model.ActionCardTypes.BUILD_ROAD: 0,
	Model.ActionCardTypes.PLENTY: 0,
	Model.ActionCardTypes.MONOPOLY: 0,
	Model.ActionCardTypes.VICTORY_POINTS: 0,
}


func keys() -> Array[Model.ActionCardTypes]: return self._data.keys()


func get_card(c: Model.ActionCardTypes) -> int:
	return self._data[c]


func set_card(c: Model.ActionCardTypes, value: int) -> void:
	assert(self._data.has(c), "ActionCardWallet: invalid card type: %s" % c)
	self._data[c] = value


func add_card(c: Model.ActionCardTypes, amount: int = 1) -> void:
	assert(self._data.has(c), "ActionCardWallet: invalid card type: %s" % c)
	self._data[c] += amount


func remove_card(c: Model.ActionCardTypes, amount: int = 1) -> void:
	assert(self._data.has(c), "ActionCardWallet: invalid card type: %s" % c)
	self._data[c] -= amount


func count_cards() -> int:
	var total: int = 0
	for c in self._data.keys():
		total += self._data[c]
	return total


func has_card(c: Model.ActionCardTypes) -> bool:
	return self._data[c] > 0


func duplicate() -> ActionCardWallet:
	var new_wallet := ActionCardWallet.new()
	for c in self._data.keys():
		new_wallet.set_card(c, self._data[c])
	return new_wallet


func to_dict() -> Dictionary[Model.ActionCardTypes, int]:
	return self._data.duplicate()


func _to_string() -> String:
	return "ActionCardWallet[Soldier:%s Road:%s Plenty:%s Monopoly:%s VP:%s]" % [
		self._data[Model.ActionCardTypes.SOLDIER],
		self._data[Model.ActionCardTypes.BUILD_ROAD],
		self._data[Model.ActionCardTypes.PLENTY],
		self._data[Model.ActionCardTypes.MONOPOLY],
		self._data[Model.ActionCardTypes.VICTORY_POINTS],
	]