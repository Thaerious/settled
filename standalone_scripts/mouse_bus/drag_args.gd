## drag_args.gd
class_name DragArgs
extends RefCounted

var texture:    Texture2D
var payload:    Variant
var size:       Vector2
var offset:     Vector2    = Vector2.ZERO
var on_success: Callable = func(_rec: DragRecord): pass
var on_failure: Callable = func(_rec: DragRecord): pass
var on_enter:   Callable = func(_rec: DragRecord): pass
var on_exit:    Callable = func(_rec: DragRecord): pass