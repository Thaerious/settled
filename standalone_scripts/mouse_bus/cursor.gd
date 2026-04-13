class_name Cursor
extends Resource

@export var table: Dictionary[String, Resource] = {}

func get_cursor(type: MouseBus.CursorType) -> CompressedTexture2D:
	var key: String = MouseBus.CursorType.keys()[type].to_lower()

	if self.table.has(key):
		return self.table.get(key)
	elif self.table.has("default"):
		return self.table.get("default")
	else:
		push_error("No cursor with key '%s' found, and no default found." % key)
		return null
