@tool
extends DraggableDialogControl

@export var road_controller:Node

func _ready() -> void:
	super._ready()
	self._drag_node.drag_start.connect(self._on_drag_start)
	self._drag_node.drag_end.connect(self._on_drag_start)


func _on_drag_start() -> void:
	EventBus.show_initial_house_targets.emit()


func _on_drag_end(_rec: DragRecord) -> void:
	pass