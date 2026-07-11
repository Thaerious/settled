class_name MonopolyDialog
extends Control


var _selected_panel: SelectablePanelContainer = null


func _ready() -> void:
	EventBus.current_phase_updated.connect(self._update_phase)

	EventBus.model_loaded.connect(func(): 
		self._update_phase(Game.model.get_current_phase())
	)


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
