@tool
extends DraggableDialogControl

var _last_target: CornerTarget = null
const HOUSE_PIECE: PackedScene = preload("res://game_board/house_piece.tscn")


func _ready() -> void:
	super._ready()
	self._drag_node.drag_start.connect(self._on_drag_start)
	self._drag_node.drag_end.connect(self._on_drag_end)
	self._drag_node.hover_enter.connect(self._on_hover_enter)
	self._drag_node.hover_exit.connect(self._on_hover_exit)


func _on_drag_start() -> void:
	EventBus.show_house_targets.emit()


func _on_drag_end(rec: DragRecord) -> void:
	EventBus.clear_targets.emit()
	if not rec.destination: return
	if not rec.destination.owner is CornerTarget: return
	self._last_target = rec.destination.owner
	EventBus.request_house.emit(Game.self_id, self._last_target.axial)	


func _on_hover_enter(rec: DragRecord) -> void:
	if not rec.destination.owner is CornerTarget: return
	self._last_target = rec.destination.owner	 as CornerTarget
	var house_piece = HOUSE_PIECE.instantiate()
	house_piece.modulate = GameBoard.tint[Game.self_id]
	self._last_target.set_piece(house_piece)


func _on_hover_exit(_rec: DragRecord) -> void:
	self._last_target.clear_piece()
	self._last_target = null
