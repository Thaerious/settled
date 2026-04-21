## axial_set.gd
## A set collection for Axial values. Guarantees uniqueness with no duplicate entries.
class_name AxialSet
extends RefCounted

var _data: Dictionary[Vector3i, bool] = {}
var _iter_index: int = 0
var _iter_keys: Array = []


# Populates the set from an optional initial array of Axial values.
# AxialSet.new([A, B, C]) → {A, B, C}
func _init(items: Array = []) -> void:
	for item in items:
		self._data[self._key(item)] = true


# Converts an Axial to a Vector3i for use as a dictionary key.
# Axial(1, 2, -3) → Vector3i(1, 2, -3)
func _key(ax: Axial) -> Vector3i:
	return Vector3i(ax.q, ax.r, ax.s)


# Called by the engine at the start of a for-in loop; captures current keys.
# for ax in set → initialises iteration snapshot
func _iter_init(_arg) -> bool:
	self._iter_keys = self._data.keys()
	self._iter_index = 0
	return self._iter_keys.size() > 0


# Called by the engine each iteration step; advances the cursor.
# index 0 → 1 → 2 … until exhausted
func _iter_next(_arg) -> bool:
	self._iter_index += 1
	return self._iter_index < self._iter_keys.size()


# Called by the engine to yield the current element during iteration.
# keys[index] → Axial
func _iter_get(_arg) -> Axial:
	return self._vec_to_axial(self._iter_keys[self._iter_index])


# Converts a stored Vector3i key back into an Axial value.
# Vector3i(1, 2, -3) → Axial(1, 2, -3)
func _vec_to_axial(v: Vector3i) -> Axial:
	return Axial.new(v.x, v.y, v.z)


# Returns true if the set contains the given Axial.
# A in {A, B, C} → true
func has_item(ax: Axial) -> bool:
	return self._data.has(self._key(ax))


## Adds [param ax] to the set. Has no effect if already present.
# {A, B} + C → {A, B, C}
func add_item(ax: Axial) -> AxialSet:
	self._data[self._key(ax)] = true
	return self


## Removes [param ax] from the set. Has no effect if not present.
# {A, B, C} - B → {A, C}
func remove_item(ax: Axial) -> AxialSet:
	self._data.erase(self._key(ax))
	return self


## Returns [code]true[/code] if [param ax] is in the set.
# A in {A, B, C} → true
func contains(ax: Axial) -> bool:
	return self._key(ax) in self._data


## Adds all items from [param items] to the set.
# {A, B} + [C, D] → {A, B, C, D}
func add_all(items: Variant) -> AxialSet:
	for item in items:
		self._data[self._key(item)] = true
	return self


## Removes all items from the set.
# {A, B, C} → {}
func clear() -> AxialSet:
	self._data.clear()
	return self


## Returns the number of items in the set.
# |{A, B, C}| → 3
func size() -> int:
	return self._data.size()


# Returns a string representation of the internal key array.
# {A, B, C} → "[(1,0,-1), (0,1,-1), (1,-1,0)]"
func _to_string() -> String:
	return "AxialSet" + str(self._data.keys())


## Returns all items as an [Array] of [Axial].
# {A, B, C} → [A, B, C]
func to_array() -> Array[Axial]:
	var result: Array[Axial] = []
	for v in self._data.keys():
		result.append(self._vec_to_axial(v))
	return result


# Calls cb for every Axial in the set; returns self for chaining.
# {A, B, C}.for_each(fn) → fn(A), fn(B), fn(C)
func for_each(cb: Callable) -> AxialSet:
	for ax: Axial in self:
		cb.call(ax)
	return self


# Returns a new set containing only elements present in both sets.
# {A, B, C} & {B, C, D} → {B, C}
func intersect(that: AxialSet) -> AxialSet:
	var aset := AxialSet.new()
	for v in self._data:
		if that._data.has(v):
			aset._data[v] = true
	return aset


# Returns a new set with elements in this set that are not in that set.
# {A, B, C} \ {B, C, D} → {A}
func difference(that: AxialSet) -> AxialSet:
	var aset := AxialSet.new()
	for v in self._data:
		if not that._data.has(v):
			aset._data[v] = true
	return aset


# Returns a new set containing all elements from both sets.
# {A, B, C} | {B, C, D} → {A, B, C, D}
func union(that: AxialSet) -> AxialSet:
	var aset := AxialSet.new()
	aset._data.merge(self._data)
	aset._data.merge(that._data)
	return aset


## Returns a new set with all coordinates offset by [param ax].
# {A, B, C}.transform(D) → {A+D, B+D, C+D}
func transform(ax: Axial) -> AxialSet:
	var aset := AxialSet.new()
	for v in self._data:
		aset._data[v + Vector3i(ax.q, ax.r, ax.s)] = true
	return aset


## Returns a new set with all coordinates scaled by [param scaler].
# {A, B, C}.scale(2) → {A*2, B*2, C*2}
func scale(scaler: float) -> AxialSet:
	var aset := AxialSet.new()
	for v in self._data:
		aset._data[Vector3i(v * scaler)] = true
	return aset


# Returns a new set by applying cb to each element; cb must return an Axial.
# {A, B, C}.map(fn) → {fn(A), fn(B), fn(C)}
func map(cb: Callable) -> AxialSet:
	var aset := AxialSet.new()
	for v in self._data:
		aset.add_item(cb.call(self._vec_to_axial(v)))
	return aset


# Maps each element to a set via cb, then flattens all results into one set.
# {A, B}.flat_map(fn) → fn(A) | fn(B)
func flat_map(cb: Callable) -> AxialSet:
	var aset := AxialSet.new()
	for v in self._data:
		aset.add_all(cb.call(self._vec_to_axial(v)))
	return aset


# Maps each element to a set via cb, then flattens all results into one set.
# {A, B}.flat_map(fn) → fn(A) | fn(B)
func edge_map(cb: Callable) -> AxialEdgeSet:
	var aset := AxialEdgeSet.new()
	for v in self._data:
		aset.add_all(cb.call(self._vec_to_axial(v)))
	return aset


# Returns a new set containing only elements for which cb returns true.
# {A, B, C}.select(fn) → {x | fn(x) == true}
func select(cb: Callable) -> AxialSet:
	var aset := AxialSet.new()
	for v in self._data:
		var ax := self._vec_to_axial(v)
		if cb.call(ax):
			aset._data[v] = true
	return aset


# Returns a shallow copy of this set.
# {A, B, C}.clone() → {A, B, C}
func clone() -> AxialSet:
	var aset := AxialSet.new()
	aset._data.merge(self._data)
	return aset
