## drag_record.gd
class_name DragRecord

## A snapshot of a drag operation's state, passed to DragArgs callbacks.

## The drop target the drag interacted with, or null if none.
var destination: Variant

## Cursor position in the local coordinate space of the drop target.
var local_pos:   Vector2

## Cursor position in world space.
var world_pos:   Vector2

## Cursor position in screen (viewport) space.
var screen_pos:  Vector2

func _to_string():
	return "DragRecord | destination: %s | local_pos: %s | world_pos: %s | screen_pos: %s" % [destination, local_pos, world_pos, screen_pos]