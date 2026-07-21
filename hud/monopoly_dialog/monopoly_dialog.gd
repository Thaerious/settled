@tool
class_name MonopolyDialog
extends DialogControl


var _selected_control: SelectableSpriteControl = null

@onready var _controls: Dictionary[SelectableSpriteControl, Model.ResourceTypes] = {
	%WoodControl: Model.ResourceTypes.WOOD,
	%BrickControl: Model.ResourceTypes.BRICK,
	%WheatControl: Model.ResourceTypes.WHEAT,
	%RockControl: Model.ResourceTypes.ROCK,
	%WoolControl: Model.ResourceTypes.WOOL
}


func _post_ready() -> void:
	super._post_ready()
	EventBus.current_phase_updated.connect(self._update_phase)

	EventBus.model_loaded.connect(func(): 
		self._update_phase(Game.model.get_current_phase())
	)

	%ButtonAccept.pressed.connect(self._accept)

	for _control in self._controls.keys():
		var control := _control as SelectableSpriteControl
		control.on_selected.connect(func():
			if self._selected_control:
				self._selected_control.selected = false
			
			self._selected_control = control
		)

	%WoodControl.selected = true


func _accept() -> void:
	var resource := self._controls[self._selected_control]
	EventBus.play_monopoly_card.emit(Game.self_id, resource)


func _update_phase(phase: Model.GamePhase) -> void:
	self.visible = false	

	if phase != Model.GamePhase.MONOPOLY: return
	if not Game.model.get_current_player() == Game.self_id: return

	self.visible = true	


func _on_panel_selected(panel: SelectablePanelContainer) -> void:
	if self._selected_panel:
		self._selected_panel.selected = false
			
	panel.selected = true
	self._selected_panel = panel
	%ButtonAccept.disabled = false
