## drag_record.gd
class_name DragRecord

## A snapshot of a drag operation's state, passed to DragArgs callbacks.

## The node that was picked up and dragged.
var draggable:   Node

## The drop target the drag interacted with, or null if none.
var destination: Variant

## The payload carried from the originating DragArgs.
var payload:     Variant

## Cursor position in the local coordinate space of the drop target.
var local_pos:   Vector2

## Cursor position in world space.
var world_pos:   Vector2

## Cursor position in screen (viewport) space.
var screen_pos:  Vector2