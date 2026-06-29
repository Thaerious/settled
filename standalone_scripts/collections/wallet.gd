class_name Wallet
extends RefCounted


var _iter_index: int = 0
var _iter_array: Array = []


var _data: Dictionary[Model.ResourceTypes, int] = {
	Model.ResourceTypes.BRICK: 0,
	Model.ResourceTypes.WOOD:  0,
	Model.ResourceTypes.WHEAT: 0,	
	Model.ResourceTypes.WOOL:  0,
	Model.ResourceTypes.ROCK:  0,	
}


func _init(initial: Variant = null) -> void:
	if initial == null:
		return
	elif initial is int:
		self.set_all(initial)
	else:
		self.copy_from(initial)


func _iter_init(_arg) -> bool:
	self._iter_array = self.to_array()
	self._iter_index = 0
	return self._iter_array.size() > 0


func _iter_next(_arg) -> bool:
	self._iter_index += 1
	return self._iter_index < self._iter_array.size()


func _iter_get(_arg) -> Model.ResourceTypes:
	return self._iter_array[self._iter_index]


func duplicate() -> Wallet:
	return  Wallet.new(self)


var brick: int:
	get: return self.get_resource(Model.ResourceTypes.BRICK)
	set(v): self.set_resource(Model.ResourceTypes.BRICK, v)


var wood: int:
	get: return self.get_resource(Model.ResourceTypes.WOOD)
	set(v): self.set_resource(Model.ResourceTypes.WOOD, v)


var wool: int:
	get: return self.get_resource(Model.ResourceTypes.WOOL)
	set(v): self.set_resource(Model.ResourceTypes.WOOL, v)


var wheat: int:
	get: return self.get_resource(Model.ResourceTypes.WHEAT)
	set(v): self.set_resource(Model.ResourceTypes.WHEAT, v)


var rock: int:
	get: return self.get_resource(Model.ResourceTypes.ROCK)
	set(v): self.set_resource(Model.ResourceTypes.ROCK, v)


# retain only the specified
func keep_only(resouce: Model.ResourceTypes) -> void:
	for r in self._data.keys():
		if r != resouce: self.set_resource(r, 0)


func keys() -> Array[Model.ResourceTypes]: return self._data.keys()


func get_resource(r: Model.ResourceTypes) -> int:
	return self._data[r]


func set_all(amount: int) -> void:
	for r in self._data.keys():
		self.set_resource(r, amount)	


func set_resource(r: Model.ResourceTypes, value: int) -> void:
	assert(self._data.has(r), "Wallet: invalid resource type: %s" % r)
	self._data[r] = value


func add_resource(r: Model.ResourceTypes, amount: int = 1) -> void:
	assert(self._data.has(r), "Wallet: invalid resource type: %s" % r)
	self._data[r] += amount


func remove_resource(r: Model.ResourceTypes, amount: int = 1) -> void:
	assert(self._data.has(r), "Wallet: invalid resource type: %s" % r)
	self._data[r] -= amount


func copy_from(that: Variant) -> void:
	if that is Dictionary:
		for r in self._data.keys(): self.set_resource(r, that[r])
	elif that is Wallet:
		for r in self._data.keys(): self.set_resource(r, that.get_resource(r))
	else: # array
		self.set_all(0)
		for r in that: self.add_resource(r)


func add_resources(that: Variant) -> void:
	if that is Dictionary:
		for r in self._data.keys(): self.add_resource(r, that[r])
	elif that is Wallet:
		for r in self._data.keys(): self.add_resource(r, that.get_resource(r))
	else: # array
		for r in that: self.add_resource(r)


func remove_resources(that: Variant) -> void:
	if that is Dictionary:
		for r in self._data.keys(): self.remove_resource(r, that[r])
	elif that is Wallet:
		for r in self._data.keys(): self.remove_resource(r, that.get_resource(r))
	else: # array 
		for r in that: self.remove_resource(r)


func to_dict() -> Dictionary[Model.ResourceTypes, int]:
	return self._data.duplicate()


func to_array() -> Array[Model.ResourceTypes]:
	var result: Array[Model.ResourceTypes] = []
	for r in self._data.keys():
		for i in range(self._data[r]):
			result.append(r)
	return result


func size() -> int:
	var total: int = 0
	for r in self._data.keys():
		total += self._data[r]
	return total


func has_resource(r: Model.ResourceTypes) -> bool:
	return self._data[r] > 0


func has_resources(that: Wallet) -> bool:
	if self._data[Model.ResourceTypes.BRICK] < that.brick: return false
	if self._data[Model.ResourceTypes.WOOD]  < that.wood:  return false
	if self._data[Model.ResourceTypes.ROCK]  < that.rock:  return false
	if self._data[Model.ResourceTypes.WHEAT] < that.wheat: return false
	if self._data[Model.ResourceTypes.WOOL]  < that.wool:  return false
	return true


func update_view(views: Dictionary, format: String = "%s", field: String = "text") -> void:
	for r in self.keys(): 
		if not views.has(r): continue
		var control = views[r]
		if control.get(field) == null: continue
		views[r].set(field, format % self.get_resource(r))


func _to_string() -> String:
	return "Wallet[Bk:%s Wd:%s Rk:%s Wt:%s Wl:%s]" % [
		self._data[Model.ResourceTypes.BRICK],
		self._data[Model.ResourceTypes.WOOD],
		self._data[Model.ResourceTypes.ROCK],
		self._data[Model.ResourceTypes.WHEAT],
		self._data[Model.ResourceTypes.WOOL],
	]


func serialize() -> Array:
	return self._data.values()


static func deserialize(array: Array) -> Wallet:
	var wallet := Wallet.new()
	for i in array.size():
		wallet.set_resource(i, array[i])

	return wallet	
