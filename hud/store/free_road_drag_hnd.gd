class_name FreeRoadDragHnd
extends DragHandler

const texture: Texture2D = preload("res://assets/road_piece.png")
const texture_size = Vector2(32,32)
const ROAD_PIECE: PackedScene = preload("res://game_board/road_piece.tscn")

var _road_piece = ROAD_PIECE.instantiate()
var _marked_edges: AxialEdgeSet = AxialEdgeSet.new()
var _last_target: EdgeTarget = null


func _init(road_trigger: StoreItemContainer) -> void:
	super._init(road_trigger)
	self.mask = 0x02


func _start_drag() -> void:
	self._road_piece = ROAD_PIECE.instantiate()
	EventBus.show_road_targets.emit()


func _on_success(_rec: DragRecord) -> void:
	EventBus.clear_targets.emit()
	self._marked_edges.add_item(self._last_target.axial_edge)	

	if self._marked_edges.size() == 2:
		for edge in self._marked_edges:
			EventBus.request_road.emit(Game.self_id, edge)
			EventBus.request_update_phase.emit(Model.GamePhase.MAIN)
	else:
		EventBus.set_road_view_only.emit(Game.self_id, self._last_target.axial_edge)			
		self._marked_edges.add_item(self._last_target.axial_edge)
		
	self._last_target = null


func _on_failure(_rec: DragRecord) -> void:
	EventBus.clear_targets.emit()
	self._last_target = null


func _on_enter(rec: HoverRecord) -> void:	
	if not rec.entered.owner is EdgeTarget: return		
	print("on enter %s" % rec.entered.owner.axial_edge)

	var target := rec.entered.owner as EdgeTarget
	if target == self._last_target: return  # already set, ignore
	rec.draggable.visible = false
	if self._last_target: self._last_target.clear_piece()
	self._last_target = rec.entered.owner as EdgeTarget
	self._last_target.set_piece(self._road_piece)
	self._road_piece.rotation = target.axial_edge.rotation


func _on_exit(rec: HoverRecord) -> void:
	if not rec.exited.owner is EdgeTarget: return	
	print("on exit %s" % rec.exited.owner.axial_edge)

	var target := rec.exited.owner as EdgeTarget
	if target != self._last_target: return  # already moved on, ignore

	rec.draggable.visible = true
	self._last_target.clear_piece()
	self._last_target = null
