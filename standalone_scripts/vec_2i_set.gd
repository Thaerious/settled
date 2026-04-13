## vec2i_set.gd
## A set collection for Vector2i values. Guarantees uniqueness with no duplicate entries.
class_name Vec2iSet
extends RefCounted


var _data: Dictionary = {}


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
func add_all(items: Array[Vector2i]) -> void:
	for item in items:
		self._data[item] = true


## Removes all items from the set.
func clear() -> void:
	self._data.clear()


## Returns the number of items in the set.
func size() -> int:
	return self._data.size()


## Returns all items as an [Array] of [Vector2i].
func to_array() -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	result.assign(self._data.keys())
	return result