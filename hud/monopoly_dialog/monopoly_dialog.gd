@tool
class_name MonopolyDialog
extends DialogContainer


func _ready() -> void:
	super._ready()
	%SelectableHBox.on_selection_changed.connect(self._hnd_selection_changed)
	%ButtonAccept.pressed.connect(self._accept)


func  _hnd_selection_changed(_target: Node):
	%ButtonAccept.disabled = false


func _hnd_current_phase_updated(phase: Model.GamePhase) -> void:
	self.visible = false
	if phase != Model.GamePhase.MONOPOLY: return
	if Game.model.get_current_player() != Game.self_id: return
	self.visible = true


func _accept() -> void:
	var selected_node = %SelectableHBox.current_selection as MonoplyControl
	if not selected_node: return
	var resource = selected_node.resource
	EventBus.play_monopoly_card.emit(Game.self_id, resource)
