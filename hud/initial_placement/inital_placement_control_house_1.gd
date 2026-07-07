@tool
extends DraggableDialogControl

@export var road_controller:Node
var _last_target: CornerTarget = null


func _ready() -> void:
	super._ready()
	self._drag_node.drag_start.connect(self._on_drag_start)
	self._drag_node.drag_end.connect(self._on_drag_end)
	self._drag_node.hover_enter.connect(self._on_hover_enter)


func _on_drag_start() -> void:
	EventBus.show_initial_house_targets.emit()


func _on_drag_end(_rec: DragRecord) -> void:
	EventBus.clear_targets.emit()
	EventBus.set_house_view_only.emit(Game.self_id, self._last_target.axial)
	self.road_controller.house = self._last_target.axial


func _on_hover_enter(rec: DragRecord) -> void:
	print(rec)
