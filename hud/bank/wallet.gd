class_name Wallet
extends RefCounted


var _linked_view: Dictionary = {}
var _iter_index: int = 0
var _iter_array: Array = []


var _data: Dictionary[Model.ResourceTypes, int] = {
	Model.ResourceTypes.BRICK: 0,
	Model.ResourceTypes.WOOD:  0,
	Model.ResourceTypes.ROCK:  0,
	Model.ResourceTypes.WHEAT: 0,
	Model.ResourceTypes.WOOL:  0,
}


func _init(initial: Array = []) -> void:
	for r in initial: self.add_resource(r)


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
	var new_wallet = Wallet.new()
	new_wallet.add_resources(self)
	return new_wallet


# retain only the specified
func keep(resouce: Model.ResourceTypes) -> void:
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
	self.trigger_linked_view(r)


func add_resource(r: Model.ResourceTypes, amount: int = 1) -> void:
	assert(self._data.has(r), "Wallet: invalid resource type: %s" % r)
	self._data[r] += amount
	self.trigger_linked_view(r)


func remove_resource(r: Model.ResourceTypes, amount: int = 1) -> void:
	assert(self._data.has(r), "Wallet: invalid resource type: %s" % r)
	self._data[r] -= amount
	self.trigger_linked_view(r)


func copy_from(that: Wallet) -> void:
	for r in self._data.keys():
		self.set_resource(r, that.get_resource(r))


func add_resources(that: Wallet) -> void:
	for r in self._data.keys():
		self.add_resource(r, that.get_resource(r))


func remove_resources(that: Wallet) -> void:
	for r in self._data.keys():
		self.remove_resource(r, that.get_resource(r))


func add_resources_to(that: Wallet) -> void:
	that.add_resources(self)


func remove_resources_from(that: Wallet) -> void:
	that.remove_resources(self)


func to_dict() -> Dictionary[Model.ResourceTypes, int]:
	return self._data.duplicate()


func to_array() -> Array[Model.ResourceTypes]:
	var result: Array[Model.ResourceTypes] = []
	for r in self._data.keys():
		for i in range(self._data[r]):
			result.append(r)
	return result


func count_resources() -> int:
	var total: int = 0
	for r in self._data.keys():
		total += self._data[r]
	return total


func has_resource(r: Model.ResourceTypes) -> bool:
	return self._data[r] > 0


func has_resources(brick: int, wood: int, rock: int, wheat: int, wool: int) -> bool:
	if self._data[Model.ResourceTypes.BRICK] < brick: return false
	if self._data[Model.ResourceTypes.WOOD]  < wood:  return false
	if self._data[Model.ResourceTypes.ROCK]  < rock:  return false
	if self._data[Model.ResourceTypes.WHEAT] < wheat: return false
	if self._data[Model.ResourceTypes.WOOL]  < wool:  return false
	return true


func link_view(views: Dictionary):
	self._linked_view = views
	for r in self.keys(): self.trigger_linked_view(r)


func trigger_linked_view(r: Model.ResourceTypes) -> void:
	if not self._linked_view.has(r): return
	var control = self._linked_view[r]
	if control.get("text") == null: return
	self._linked_view[r].text = str(self.get_resource(r))


func _to_string() -> String:
	return "Wallet[Bk:%s Wd:%s Rk:%s Wt:%s Wl:%s]" % [
		self._data[Model.ResourceTypes.BRICK],
		self._data[Model.ResourceTypes.WOOD],
		self._data[Model.ResourceTypes.ROCK],
		self._data[Model.ResourceTypes.WHEAT],
		self._data[Model.ResourceTypes.WOOL],
	]
