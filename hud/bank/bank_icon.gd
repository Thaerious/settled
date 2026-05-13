class_name BankIcon
extends TextureRect

@export var resource := Model.ResourceTypes.NONE
var can_drop: bool = true


func _gui_input(event) -> void:
	if self._dev_gui_input(event): return

	# drag-drop resource exchange
	if not event is InputEventMouseButton: return
	if event.button_index != MouseButton.MOUSE_BUTTON_LEFT: return
	if not event.pressed: return

	# don't start drag if it's not your turn
	if Game.model.get_current_player() != Game.self_id: return

	# dont' start drag if it's not the main phase
	if Game.model.get_current_phase() != Model.GamePhase.MAIN: return

	# don't start drag if there is not enough resources
	var rate = Game.model.get_exchange_rate(Game.self_id, self.resource)
	var count = Game.model.get_bank(Game.self_id).get_resource(self.resource)
	if count < rate: return

	var drag_args = DragArgs.new()
	drag_args.texture = self.texture
	drag_args.size = Vector2(32, 32)
	drag_args.offset = Vector2(16, 16)
	drag_args.on_success = self._on_drop
	MouseBus.start_drag(drag_args)


func _on_drop(rec: DragRecord) -> void:
	if not rec.destination is BankIcon: return
	if self.resource == rec.destination.resource: return
	EventBus.request_exchange.emit(Game.self_id, self.resource, rec.destination.resource)


# for dev/debug adding resources
func _dev_gui_input(event) -> bool:
	if not event is InputEventMouseButton: return false
	var mouse_event = event as InputEventMouseButton
	if mouse_event.button_index != MouseButton.MOUSE_BUTTON_LEFT: return false
	if not mouse_event.pressed: return false
	if not mouse_event.ctrl_pressed: return false

	var wallet = Wallet.new([resource])

	if mouse_event.shift_pressed:
		Game.model.do_remove_resources(Game.self_id, wallet)
	else:
		Game.model.do_add_resources(Game.self_id, wallet)
	
	return true
	