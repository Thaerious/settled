## axial_set.gd
## A set collection for Axial values. Guarantees uniqueness with no duplicate entries.
class_name AxialSet
extends RefCounted

var _data: Dictionary[String, Axial] = {}
var _iter_index: int = 0
var _item_values: Array[Axial] = []


# Populates the set from an optional initial array of Axial values.
# AxialSet.new([A, B, C]) → {A, B, C}
func _init(items: Array[Axial] = []) -> void:
	for item in items:
		self._data[item.key()] = item


# Called by the engine at the start of a for-in loop; captures current keys.
# for ax in set → initialises iteration snapshot
func _iter_init(_arg) -> bool:
	self._item_values = self._data.values()
	self._iter_index = 0
	return self._item_values.size() > 0


# Called by the engine each iteration step; advances the cursor.
# index 0 → 1 → 2 … until exhausted
func _iter_next(_arg) -> bool:
	self._iter_index += 1
	return self._iter_index < self._item_values.size()


# Called by the engine to yield the current element during iteration.
# keys[index] → Axial
func _iter_get(_arg) -> Axial:
	return self._item_values[self._iter_index]


# Returns true if the set contains the given Axial.
# A in {A, B, C} → true
func has_item(ax: Axial) -> bool:
	return self._data.has(ax.key())


## Adds [param ax] to the set. Has no effect if already present.
# {A, B} + C → {A, B, C}
func add_item(ax: Axial) -> AxialSet:
	self._data[ax.key()] = ax
	return self


## Removes [param ax] from the set. Has no effect if not present.
# {A, B, C} - B → {A, C}
func remove_item(ax: Axial) -> AxialSet:
	self._data.erase(ax.key())
	return self


## Returns [code]true[/code] if [param ax] is in the set.
# A in {A, B, C} → true
func contains(ax: Axial) -> bool:
	return ax.key() in self._data


## Adds all items from [param items] to the set.
# {A, B} + [C, D] → {A, B, C, D}
func add_all(items: Variant) -> AxialSet:
	for item in items:
		var ax = item as Axial
		self._data[ax.key()] = ax
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
	for ax in self._data.values():
		result.append(ax)
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
	for ax in self:
		if that.has_item(ax):
			aset.add_item(ax)
	return aset


# Returns a new set with elements in this set that are not in that set.
# {A, B, C} \ {B, C, D} → {A}
func difference(that: AxialSet) -> AxialSet:
	var aset := AxialSet.new()
	for ax in self:
		if not that.has_item(ax):
			aset.add_item(ax)
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
func transform(bx: Axial) -> AxialSet:
	var aset := AxialSet.new()
	for ax in self:
		aset.add_item(ax.transform(bx))
	return aset


## Returns a new set with all coordinates scaled by [param x].
# {A, B, C}.scale(2) → {A*2, B*2, C*2}
func scale(x: int) -> AxialSet:
	var aset := AxialSet.new()
	for ax in self:
		aset.add_item(ax.scale(x))
	return aset


# Returns a new set by applying cb to each element; cb must return an Axial.
# {A, B, C}.map(fn) → {fn(A), fn(B), fn(C)}
func map(cb: Callable) -> AxialSet:
	var aset := AxialSet.new()
	for ax in self:
		var result = cb.call(ax)
		if result is Axial: 
			aset.add_item(result)
		elif result is Array or result is Dictionary or result.has_method("_iter_init"):
			aset.add_all(result)
	return aset


# Maps each element to a set via cb, then flattens all results into one set.
# {A, B}.flat_map(fn) → fn(A) | fn(B)
func flat_map(cb: Callable) -> AxialSet:
	var aset := AxialSet.new()
	for ax in self:
		aset.add_all(cb.call(ax))		
	return aset


func map_to_array(cb: Callable) -> Array:
	var an_array := []
	for ax in self:
		var result = cb.call(ax)
		if result is Array:	an_array.append_array(result)
		else: an_array.append(result)
	return an_array	


# Maps each element to a set via cb, then flattens all results into one set.
# Maps corners to edges
# {A, B}.flat_map(fn) → fn(A) | fn(B)
func edge_map(cb: Callable) -> AxialEdgeSet:
	var aset := AxialEdgeSet.new()
	for ax in self:
		aset.add_all(cb.call(ax))
	return aset


# Returns a new set containing only elements for which cb returns true.
# {A, B, C}.select(fn) → {x | fn(x) == true}
func select(cb: Callable) -> AxialSet:
	var aset := AxialSet.new()
	for ax in self:
		if cb.call(ax):
			aset.add_item(ax)
	return aset


# Returns a copy of this set.
# {A, B, C}.duplicate() → {A, B, C}
func duplicate(deep: bool = false) -> AxialSet:
	var aset := AxialSet.new()
	if deep:
		for ax in self:
			aset.add_item(ax.duplicate())
	else:
		aset._data = self._data.duplicate()
	return aset


func serialize() -> Array:
	return self._data.keys()


static func deserialize(data: Array) -> AxialSet:
	var aset := AxialSet.new()
	for key in data:
		aset.add_item(Axial.from_key(key))
	return aset