# mouse_area_2d.gd
class_name MouseArea2D
extends Area2D

@export var disabled: bool = false
@export var cursor:MouseBus.CursorType = MouseBus.CursorType.POINTER

func _ready():
	self.mouse_entered.connect(self._on_mouse_entered)
	self.mouse_exited.connect(self._on_mouse_exited)

func _on_mouse_entered() -> void:	
	if self.disabled: return	
	if MouseBus.is_dragging(): return
	MouseBus.set_cursor(self.cursor)

func _on_mouse_exited() -> void:
	if self.disabled: return
	if MouseBus.is_dragging(): return
	MouseBus.clear_cursor()
