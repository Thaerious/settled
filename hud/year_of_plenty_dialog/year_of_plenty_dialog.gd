@tool
class_name YearOfPlentyDialog
extends DialogContainer


func _ready() -> void:
	EventBus.current_phase_updated.connect(self._update_phase)
	%ButtonAccept.pressed.connect(self._accept)


func _update_phase(phase: Model.GamePhase) -> void:
	if phase != Model.GamePhase.YEAR_OF_PLENTY: self.visible = false	
	else: self.visible = true


func _accept() -> void:
	EventBus.play_plenty_card.emit(Game.self_id, %ControlGroup.wallet)