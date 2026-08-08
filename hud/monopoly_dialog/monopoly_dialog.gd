@tool
class_name MonopolyDialog
extends DialogPane


const BUTTON_TO_RESOURCE = {
	0: Model.ResourceTypes.WOOD,
	1: Model.ResourceTypes.BRICK,
	2: Model.ResourceTypes.WHEAT,
	3: Model.ResourceTypes.ROCK,
	4: Model.ResourceTypes.WOOL
}


func _ready() -> void:
	print("MonopolyDialog Ready %s" % self.dialog_identifier)
	super._ready()
	%SelectableHBox.on_selection_changed.connect(self._hnd_selection_changed)
	%ButtonAccept.pressed.connect(self._accept)


func  _hnd_selection_changed(_target: Node):
	%ButtonAccept.disabled = false


func _hnd_visible_phase(phase: Model.GamePhase) -> void:
	self.visible = false
	if phase != Model.GamePhase.MONOPOLY: return
	if Game.model.get_current_player() != Game.self_id: return
	self.visible = true


func _accept() -> void:
	var idx = %SelectableHBox.current_selected_index
	if idx == -1: return
	var resource = BUTTON_TO_RESOURCE[idx]
	EventBus.play_monopoly_card.emit(Game.self_id, resource)
