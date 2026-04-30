class_name RoadDragHnd
extends DragHandler

const texture: Texture2D = preload("res://assets/road_piece.png")
const texture_size = Vector2(32,32)
const ROAD_PIECE: PackedScene = preload("res://game_board/road_piece.tscn")

var _road_piece = ROAD_PIECE.instantiate()
var _last_target: EdgeTarget = null


func _start_drag() -> void:
	self._road_piece = ROAD_PIECE.instantiate()
	EventBus.show_road_targets.emit()


func _on_success(_rec: DragRecord) -> void:
	EventBus.clear_targets.emit()

	if self._last_target: 
		EventBus.set_road.emit(Game.self_id, _last_target.axial_edge)	
		self._last_target = null


func _on_failure(_rec: DragRecord) -> void:
	EventBus.clear_targets.emit()
	self._last_target = null


func _on_enter(rec: HoverRecord) -> void:	
	if not rec.entered.owner is EdgeTarget: return		

	var target := rec.entered.owner as EdgeTarget
	if target == self._last_target: return  # already set, ignore
	print("_on_enter")
	rec.draggable.visible = false
	if self._last_target: self._last_target.clear_piece()
	self._last_target = rec.entered.owner as EdgeTarget
	self._last_target.set_piece(self._road_piece)
	self._road_piece.rotation = target.axial_edge.rotation
	

func _on_exit(rec: HoverRecord) -> void:
	if not rec.exited.owner is EdgeTarget: return	

	var target := rec.exited.owner as EdgeTarget
	if target != self._last_target: return  # already moved on, ignore

	rec.draggable.visible = true
	self._last_target.clear_piece()
	self._last_target = null
