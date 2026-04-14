## drag_args.gd
class_name DragArgs
extends RefCounted

var texture:    Texture2D
var payload:    Variant
var size:       Vector2
var offset:     Vector2    = Vector2.ZERO
var on_success: Callable   = Callable()
var on_failure: Callable   = Callable()
var on_enter:   Callable   = Callable()
var on_exit:    Callable   = Callable()