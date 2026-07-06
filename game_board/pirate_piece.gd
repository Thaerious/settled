class_name PiratePiece
extends Node2D

@onready var _sprite := %Sprite2DExact
@onready var _area2d := %Area2D

func _ready() -> void:
	self._area2d.input_event.connect(self._on_input_event)


func _on_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if not event is InputEventMouseButton: return
	if event.button_index != MouseButton.MOUSE_BUTTON_LEFT: return
	if not event.pressed: return
	if Game.model.get_current_phase() != Model.GamePhase.MOVE_PIRATE: return
	if Game.model.get_current_player() != Game.self_id: return

	# TODO DRAG

	self.visible = false


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
