class_name CityDragHnd
extends DragHandler

const texture: Texture2D = preload("res://assets/city.png")
const texture_size = Vector2(32,32)
const CITY_PIECE: PackedScene = preload("res://game_board/city_piece.tscn")

var _city_piece = CITY_PIECE.instantiate()
var _last_target: CornerTarget = null


func _init(trigger) -> void:
	super._init(trigger)
	self.mask = 0x02


func _start_drag() -> void:
	self._city_piece = CITY_PIECE.instantiate()
	EventBus.show_city_targets.emit()


func _on_success(_rec: DragRecord) -> void:
	EventBus.clear_targets.emit()

	if self._last_target: 
		EventBus.set_city.emit(Game.self_id, _last_target.axial)	
		self._last_target = null


func _on_failure(_rec: DragRecord) -> void:
	EventBus.clear_targets.emit()
	self._last_target = null


func _on_enter(rec: HoverRecord) -> void:	
	if not rec.entered.owner is CornerTarget: return		

	var target := rec.entered.owner as CornerTarget
	if target == self._last_target: return  # already set, ignore

	rec.draggable.visible = false
	if self._last_target: self._last_target.clear_piece()
	self._last_target = rec.entered.owner as CornerTarget
	self._last_target.set_piece(self._city_piece)	
	

func _on_exit(rec: HoverRecord) -> void:
	if not rec.exited.owner is CornerTarget: return	

	var target := rec.exited.owner as CornerTarget
	if target != self._last_target: return  # already moved on, ignore

	rec.draggable.visible = true
	self._last_target.clear_piece()
	self._last_target = null
