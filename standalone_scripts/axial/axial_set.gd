## axial_set.gd
## A set collection for Axial values. Guarantees uniqueness with no duplicate entries.
class_name AxialSet
extends RefCounted

var _data: Dictionary[Vector3i, bool] = {}
var _iter_index: int = 0
var _iter_keys: Array = []


func _init(items: Array = []) -> void:
	for item in items:
		self._data[self._key(item)] = true


func _key(ax: Axial) -> Vector3i:
	return Vector3i(ax.q, ax.r, ax.s)


func _iter_init(_arg) -> bool:
	self._iter_keys = self._data.keys()
	self._iter_index = 0
	return self._iter_keys.size() > 0


func _iter_next(_arg) -> bool:
	self._iter_index += 1
	return self._iter_index < self._iter_keys.size()


func _iter_get(_arg) -> Axial:
	return self._vec_to_axial(self._iter_keys[self._iter_index])


func _vec_to_axial(v: Vector3i) -> Axial:
	return Axial.new(v.x, v.y, v.z)


func has_item(ax: Axial) -> bool:
	return self._data.has(self._key(ax))


## Adds [param ax] to the set. Has no effect if already present.
func add_item(ax: Axial) -> AxialSet:
	self._data[self._key(ax)] = true
	return self


## Removes [param ax] from the set. Has no effect if not present.
func remove_item(ax: Axial) -> AxialSet:
	self._data.erase(self._key(ax))
	return self


## Returns [code]true[/code] if [param ax] is in the set.
func contains(ax: Axial) -> bool:
	return self._key(ax) in self._data


## Adds all items from [param items] to the set.
func add_all(items: Variant) -> AxialSet:
	for item in items:
		self._data[self._key(item)] = true
	return self


## Removes all items from the set.
func clear() -> AxialSet:
	self._data.clear()
	return self


## Returns the number of items in the set.
func size() -> int:
	return self._data.size()


func _to_string() -> String:
	return str(self._data.keys())


## Returns all items as an [Array] of [Axial].
func to_array() -> Array[Axial]:
	var result: Array[Axial] = []
	for v in self._data.keys():
		result.append(self._vec_to_axial(v))
	return result


func for_each(cb: Callable) -> AxialSet:
	for v in self._data:
		cb.call(self._vec_to_axial(v))
	return self


func intersect(that: AxialSet) -> AxialSet:
	var aset := AxialSet.new()
	for v in self._data:
		if that._data.has(v):
			aset._data[v] = true
	return aset


func difference(that: AxialSet) -> AxialSet:
	var aset := AxialSet.new()
	for v in self._data:
		if not that._data.has(v):
			aset._data[v] = true
	return aset


func union(that: AxialSet) -> AxialSet:
	var aset := AxialSet.new()
	aset._data.merge(self._data)
	aset._data.merge(that._data)
	return aset


## Returns a new set with all coordinates offset by [param ax].
func transform(ax: Axial) -> AxialSet:
	var aset := AxialSet.new()
	for v in self._data:
		aset._data[v + Vector3i(ax.q, ax.r, ax.s)] = true
	return aset


## Returns a new set with all coordinates scaled by [param scaler].
func scale(scaler: float) -> AxialSet:
	var aset := AxialSet.new()
	for v in self._data:
		aset._data[Vector3i(v * scaler)] = true
	return aset


func map(cb: Callable) -> AxialSet:
	var aset := AxialSet.new()
	for v in self._data:
		aset.add_item(cb.call(self._vec_to_axial(v)))
	return aset


func flat_map(cb: Callable) -> AxialSet:
	var aset := AxialSet.new()
	for v in self._data:
		aset.add_all(cb.call(self._vec_to_axial(v)))
	return aset


func select(cb: Callable) -> AxialSet:
	var aset := AxialSet.new()
	for v in self._data:
		var ax := self._vec_to_axial(v)
		if cb.call(ax):
			aset._data[v] = true
	return aset


func clone() -> AxialSet:
	var aset := AxialSet.new()
	aset._data.merge(self._data)
	return aset
