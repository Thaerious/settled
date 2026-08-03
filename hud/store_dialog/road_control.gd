@tool
class_name RoadControl
extends DraggableSpriteControl

func _ready() -> void:
	super._ready()
	self.drag_node.drag_start.connect(self._on_drag_start)
	self.drag_node.drag_end.connect(self._on_drag_end)
	self.drag_node.hover_enter.connect(self._on_hover_enter)
	self.drag_node.hover_exit.connect(self._on_hover_exit)


func _on_drag_start() -> void:
	pass


func _on_drag_end(_rec: DragRecord) -> void:
	pass


func _on_hover_enter(_rec: DragRecord) -> void:
	pass


func _on_hover_exit(_rec: DragRecord) -> void:
	pass		