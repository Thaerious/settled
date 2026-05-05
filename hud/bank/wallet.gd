class_name Wallet


var _data: Dictionary[Model.ResourceTypes, int] = {
	Model.ResourceTypes.BRICK: 0,
	Model.ResourceTypes.WOOD:  0,
	Model.ResourceTypes.ROCK:  0,
	Model.ResourceTypes.WHEAT: 0,
	Model.ResourceTypes.WOOL:  0,
}


func get_resource(r: Model.ResourceTypes) -> int:
	return _data[r]


func set_resource(r: Model.ResourceTypes, value: int) -> void:
	assert(_data.has(r), "Wallet: invalid resource type: %s" % r)
	_data[r] = value


func add_resource(r: Model.ResourceTypes, amount: int) -> void:
	assert(_data.has(r), "Wallet: invalid resource type: %s" % r)
	_data[r] += amount


func to_dict() -> Dictionary[Model.ResourceTypes, int]:
	return _data.duplicate()


func to_array() -> Array[Model.ResourceTypes]:
	var result: Array[Model.ResourceTypes] = []
	for r in _data.keys():
		for i in range(_data[r]):
			result.append(r)
	return result


func count() -> int:
	var total: int = 0
	for r in _data.keys():
		total += _data[r]
	return total	