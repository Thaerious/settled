@tool
class_name RoadControl
extends DraggableSpriteControl

var _last_target: EdgeTarget = null
const ROAD_PIECE: PackedScene = preload("res://game_board/road_piece.tscn")

func _ready() -> void:
	super._ready()
	self.drag_node.drag_start.connect(self._on_drag_start)
	self.drag_node.drag_end.connect(self._on_drag_end)
	self.drag_node.hover_enter.connect(self._on_hover_enter)
	self.drag_node.hover_exit.connect(self._on_hover_exit)


func _on_drag_start() -> void:
	EventBus.show_road_targets.emit()	


func _on_drag_end(rec: DragRecord) -> void:
	EventBus.clear_targets.emit()
	if not rec.drop_target: return
	if not rec.drop_target.owner is EdgeTarget: return
	self._last_target = rec.drop_target.owner
	EventBus.request_road.emit(Game.self_id, self._last_target.axial_edge)	


func _on_hover_enter(rec: DragRecord) -> void:
	print("road control on hover enter %s" % rec)
	if not rec.drop_target: return
	if not (rec.drop_target.owner is EdgeTarget): return

	if self._last_target: self._last_target.clear_piece()
	self._last_target = rec.drop_target.owner

	var road_piece = ROAD_PIECE.instantiate()
	road_piece.modulate = GameBoard.tint[Game.self_id]
	self._last_target.set_piece(road_piece)
	road_piece.rotation = self._last_target.axial_edge.rotation


func _on_hover_exit(_rec: DragRecord) -> void:
	if not self._last_target: return
	self._last_target.clear_piece()
	self._last_target = null	
