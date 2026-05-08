## drag_args.gd
class_name DragArgs
extends RefCounted

## Encapsulates the arguments needed to initiate a drag operation.

## The visual representation shown under the cursor while dragging.
var texture:    Texture2D

## Display size of the drag preview image.
var size: Vector2

## Pixel offset from the cursor position to the top-left corner of the preview.
var offset: Vector2    = Vector2.ZERO

## The physics mask for interactions
var mask: int = 0x01

## Called when the drag ends on a valid drop target.
var on_success: Callable = func(_rec: DragRecord): pass

## Called when the drag ends without landing on a valid drop target.
var on_failure: Callable = func(_rec: DragRecord): pass

## Called when the dragged item enters a valid drop target.
var on_enter:   Callable = func(_rec: HoverRecord): pass

## Called when the dragged item leaves a valid drop target.
var on_exit:    Callable = func(_rec: HoverRecord): pass