## drag_record.gd
class_name HoverRecord

## A snapshot of a hover transition, passed to callbacks when a drag moves between drop targets.

## The node being dragged.
var draggable:  Node

## The drop target that was just left, or null if the drag entered from outside any target.
var exited:     Variant

## The drop target that was just entered, or null if the drag left without entering a new one.
var entered:    Variant

## Cursor position in the local coordinate space of the entered target.
var local_pos:  Vector2

## Cursor position in world space.
var world_pos:  Vector2

## Cursor position in screen (viewport) space.
var screen_pos: Vector2