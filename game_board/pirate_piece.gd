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

	var drag_args = DragArgs.new()
	drag_args.texture = self._sprite.texture
	drag_args.size = Vector2(64, 64)
	drag_args.offset = Vector2(-32, -32)
	drag_args.on_success = self._on_drop
	drag_args.on_failure = self._revert_drop

	self.visible = false

	MouseBus.start_drag(drag_args)


func _on_drop(rec: DragRecord):
	self.visible = true
	if not rec.destination.owner is NumberPiece: return

	var source := Game.model.get_pirate()
	var target = rec.destination.owner.axial

	self.position = rec.destination.owner.position

	print("ON DROP %s %s %s" % [target, source, target.equals(source)])

	if not target.equals(source):
		EventBus.request_set_pirate.emit(Game.self_id, target)
		EventBus.update_player_phase.emit(Game.model._current_player, Model.GamePhase.STEAL_RESOURCES)


func _revert_drop(_rec: DragRecord):
	self.visible = true
