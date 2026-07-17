class_name PiratePiece
extends Node2D

var _origin_axial = Axial.zero()

func _ready() -> void:
	%DragNode2D.drag_start.connect(self._on_drag_start)
	%DragNode2D.drag_end.connect(self._on_drag_end)
	%DragNode2D.hover_enter.connect(self._on_hover_enter)
	EventBus.current_phase_updated.connect(self._on_current_phase_updated)
	EventBus.pirate_set.connect(self._on_pirate_set)

	%DragNode2D.mouse_entered.connect(
		func(): Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	)
	%DragNode2D.mouse_exited.connect(
		func(): Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	)


func _on_drag_start() -> void:
	self._origin_axial = Game.model.get_pirate()


func _on_drag_end(rec: DragRecord) -> void:
	if not rec.drop_target.owner is NumberPiece:
		EventBus.request_set_pirate.emit(Game.self_id, self._origin_axial)
	else:
		var drop_axial = rec.drop_target.owner.axial
		EventBus.request_set_pirate.emit(Game.self_id, drop_axial)


func _on_hover_enter(rec: DragRecord) -> void:
	print(rec)


func _on_current_phase_updated(phase: Model.GamePhase) -> void:
	match phase:
		Model.GamePhase.MOVE_PIRATE: 
			%DragNode2D.disabled = false
		_: %DragNode2D.disabled = true


func _on_pirate_set(hex: Axial):
	var game_board := find_parent("GameBoard") as GameBoard
	var offset := Axial.axial_to_offset(hex)			
	self.position = game_board.tiles.map_to_local(offset)


func _on_drop(rec: DragRecord):
	self.visible = true
	if not rec.drop_target.owner is NumberPiece: return

	var source := Game.model.get_pirate()
	var target = rec.drop_target.owner.axial

	self.position = rec.drop_target.owner.position

	if not target.equals(source):
		EventBus.request_set_pirate.emit(Game.self_id, target)


func _revert_drop(_rec: DragRecord):
	self.visible = true
