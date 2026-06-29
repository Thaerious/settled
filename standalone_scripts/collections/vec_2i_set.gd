## vec2i_set.gd
## A set collection for Vector2i values. Guarantees uniqueness with no duplicate entries.
class_name Vec2iSet
extends RefCounted


var _data: Dictionary[Vector2i, bool] = {}
var _iter_index: int = 0
var _iter_keys: Array = []


func _init(items: Array = []) -> void:
	for item in items:
		self._data[Vector2i(item)] = true


func _iter_init(_arg) -> bool:
	self._iter_keys = self._data.keys()
	self._iter_index = 0
	return self._iter_keys.size() > 0


func _iter_next(_arg) -> bool:
	self._iter_index += 1
	return self._iter_index < self._iter_keys.size()


func _iter_get(_arg) -> Vector2i:
	return self._iter_keys[self._iter_index]


func has_item(item: Vector2i) -> bool:
	return self._data.has(item)


## Adds [param item] to the set. Has no effect if already present.
func add_item(item: Vector2i) -> void:
	self._data[item] = true


## Removes [param item] from the set. Has no effect if not present.
func remove_item(item: Vector2i) -> void:
	self._data.erase(item)


## Returns [code]true[/code] if [param item] is in the set.
func contains(item: Vector2i) -> bool:
	return item in self._data


## Adds all items from [param items] to the set.
## [param items] Any iterable of Vector2i values.
func add_all(items: Variant) -> void:
	for item in items:
		self._data[item] = true


## Removes all items from the set.
func clear() -> void:
	self._data.clear()


## Returns the number of items in the set.
func size() -> int:
	return self._data.size()


func _to_string() -> String:
	return str(self._data.keys())


## Returns all items as an [Array] of [Vector2i].
func to_array() -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	result.assign(self._data.keys())
	return result


# Call a function for each item in the set
func for_each(cb: Callable) -> void:
	for v in self._data:
		cb.call(v)


# Create a new set that is the intersection of two sets
# {A, B, C} & {B, C, D} = {B, C}
func intersect(that: Vec2iSet) -> Vec2iSet:
	var vset = Vec2iSet.new()
	for v in self._data:
		if that.has_item(v):
			vset.add_item(v)
	return vset


# Create a new set that is the difference between two sets
# {A, B, C} - {B, C, D} = {A}
func difference(that: Vec2iSet) -> Vec2iSet:
	var vset := Vec2iSet.new()
	for v in self._data:
		if not that.has_item(v):
			vset.add_item(v)
	return vset


# Create a new set that is the union of two sets
# {A, B, C} + {B, C, D} = {A, B, C, D}
func union(that: Vec2iSet) -> Vec2iSet:
	var vset := Vec2iSet.new()
	vset.add_all(self._data.keys())
	vset.add_all(that._data.keys())
	return vset


# Create a new set with all values offset by a scaler
# {A, B, C} + a = {A+a, B+a, C+a}
func transform(offset: Vector2i) -> Vec2iSet:
	var vset := Vec2iSet.new()
	for v in self._data:
		vset.add_item(v + offset)
	return vset


# Create a new set with all values offset by a scaler
# {A, B, C} + a = {Aa, Ba, Ca}
func scale(scaler: float) -> Vec2iSet:
	var vset := Vec2iSet.new()
	for v in self._data:
		vset.add_item(v * scaler)
	return vset


# Create a new set by applying a mapping function to each item
# {A, B, C}.map(fn) = {fn(A), fn(B), fn(C)}
func map(cb: Callable) -> Vec2iSet:
	var vset := Vec2iSet.new()
	for v in self._data:
		vset.add_item(cb.call(v))
	return vset


# Create a new set by mapping each item to a Vec2iSet and unioning all results
# {A, B}.flat_map(fn) = fn(A) | fn(B)
func flat_map(cb: Callable) -> Vec2iSet:
	var vset := Vec2iSet.new()
	for v in self._data:
		vset.add_all(cb.call(v))
	return vset


# Create a new set containing only items where the predicate returns true
# {A, B, C}.select(fn) = {v for v in {A, B, C} if fn(v)}
func select(cb: Callable) -> Vec2iSet:
	var vset := Vec2iSet.new()
	for v in self._data:
		if cb.call(v):
			vset.add_item(v)
	return vset	
