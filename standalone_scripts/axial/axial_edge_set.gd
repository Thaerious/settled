## axial_edge_set.gd
## A set collection for AxialEdge values. Guarantees uniqueness with no duplicate entries.
class_name AxialEdgeSet
extends RefCounted

var _data: Dictionary[String, AxialEdge] = {}
var _iter_index: int = 0
var _iter_keys: Array = []


# Populates the set from an optional initial array of AxialEdge values.
# AxialEdgeSet.new([E1, E2, E3]) → {E1, E2, E3}
func _init(items: Array = []) -> void:
	for item in items:
		self._data[item.key()] = item


# Called by the engine at the start of a for-in loop; captures current keys.
# for edge in set → initialises iteration snapshot
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
# keys[index] → AxialEdge
func _iter_get(_arg) -> AxialEdge:
	return self._data[self._iter_keys[self._iter_index]]


# Returns true if the set contains the given AxialEdge.
# E in {E1, E2, E3} → true
func has_item(edge: AxialEdge) -> bool:
	return self._data.has(edge.key())


# Adds edge to the set. Has no effect if already present.
# {E1, E2} + E3 → {E1, E2, E3}
func add_item(edge: AxialEdge) -> AxialEdgeSet:
	self._data[edge.key()] = edge
	return self


# Adds all items from items to the set.
# {E1, E2} + [E3, E4] → {E1, E2, E3, E4}
func add_all(items: Variant) -> AxialEdgeSet:
	for item in items:
		self._data[item.key()] = item
	return self


# Removes edge from the set. Has no effect if not present.
# {E1, E2, E3} - E2 → {E1, E3}
func remove_item(edge: AxialEdge) -> AxialEdgeSet:
	self._data.erase(edge.key())
	return self


# Removes all items from the set.
# {E1, E2, E3} → {}
func clear() -> AxialEdgeSet:
	self._data.clear()
	return self


# Returns the number of items in the set.
# |{E1, E2, E3}| → 3
func size() -> int:
	return self._data.size()


# Returns a string representation of the internal key array.
# {E1, E2, E3} → "[key1, key2, key3]"
func _to_string() -> String:
	return "EdgeSet" + str(self._data.values())


# Calls cb for every AxialEdge in the set; returns self for chaining.
# {E1, E2, E3}.for_each(fn) → fn(E1), fn(E2), fn(E3)
func for_each(cb: Callable) -> AxialEdgeSet:
	for edge: AxialEdge in self:
		cb.call(edge)
	return self


# Returns a shallow copy of this set.
# {E1, E2, E3}.clone() → {E1, E2, E3}
func clone() -> AxialEdgeSet:
	var aset := AxialEdgeSet.new()
	aset._data.merge(self._data)
	return aset


# Maps each AxialEdge to a collection of Axial corners; returns their union as an AxialSet.
# {E1, E2}.corner_map(fn) → AxialSet of all corners returned by fn
func corner_map(cb: Callable) -> AxialSet:
	var aset := AxialSet.new()
	for edge in self._data.values():
		aset.add_all(cb.call(edge))
	return aset


# Returns a new set with elements in this set that are not in that set.
# {A, B, C} \ {B, C, D} → {A}
func difference(that: AxialEdgeSet) -> AxialEdgeSet:
	var aset := AxialEdgeSet.new()
	for axial_edge in self:
		if not that.has_item(axial_edge):
			aset.add_item(axial_edge)
	return aset


# Returns a new set containing all elements from both sets.
# {A, B, C} ∪ {B, C, D} → {A, B, C, D}
func union(that: AxialEdgeSet) -> AxialEdgeSet:
	return self.clone().add_all(that)


# Returns a new set containing only elements present in both sets.
# {A, B, C} & {B, C, D} → {B, C}
func intersect(that: AxialEdgeSet) -> AxialEdgeSet:
	var aset := AxialEdgeSet.new()
	for ax in self:
		if that.has_item(ax):
			aset.add_item(ax)
	return aset


# Returns a copy of this set; deep=true duplicates each AxialEdge, shallow shares references.
# {E1, E2, E3}.duplicate(true) → {E1', E2', E3'}
func duplicate(deep: bool = false) -> AxialEdgeSet:
	var aset := AxialEdgeSet.new()
	if deep:
		for edge in self._data.values():
			aset.add_item(edge.duplicate())
	else:
		aset._data.merge(self._data)
	return aset	


func serialize() -> Array:
	return self._data.keys()


static func deserialize(data: Array) -> AxialEdgeSet:
	var aset := AxialEdgeSet.new()
	for key in data:
		aset.add_item(AxialEdge.from_key(key))
	return aset	


func map(cb: Callable) -> AxialEdgeSet:
	var aset := AxialEdgeSet.new()
	for ax in self:
		var result = cb.call(ax)
		if result is AxialEdge: 
			aset.add_item(result)
		elif result is Array or result is Dictionary or result.has_method("_iter_init"):
			aset.add_all(result)
		else:
			push_warning("Unhandled map result of type '%s' ignored." % result.get_class())			
	return aset