class_name PiratePiece
extends Node2D

var _origin_axial = Axial.zero()

func _ready() -> void:
	%DragNode2D.drag_start.connect(self._on_drag_start)
	%DragNode2D.drag_end.connect(self._on_drag_end)
	EventBus.current_phase_updated.connect(self._on_current_phase_updated)
	EventBus.pirate_set.connect(self._on_pirate_set)

func _on_drag_start() -> void:
	self._origin_axial = Game.model.get_pirate()


func _on_drag_end(_rec: DragRecord) -> void:
	EventBus.request_set_pirate.emit(Game.self_id, self._origin_axial)


func _on_current_phase_updated(phase: Model.GamePhase) -> void:
	match phase:
		Model.GamePhase.MOVE_PIRATE: 
			%DragNode2D.disabled = false
		_: %DragNode2D.disabled = true


func _on_pirate_set(hex: Axial):
	print("on pirate set")
	var offset := Axial.axial_to_offset(hex)			
	self.position = self._board.tiles.map_to_local(offset)


func _on_drop(rec: DragRecord):
	self.visible = true
	if not rec.destination.owner is NumberPiece: return

	var source := Game.model.get_pirate()
	var target = rec.destination.owner.axial

	self.position = rec.destination.owner.position

	if not target.equals(source):
		EventBus.request_set_pirate.emit(Game.self_id, target)


func _revert_drop(_rec: DragRecord):
	self.visible = true
