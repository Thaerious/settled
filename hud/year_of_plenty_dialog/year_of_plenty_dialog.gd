@tool
class_name YearOfPlentyDialog
extends DialogContainer

var _wallet = Wallet.new()

func _ready() -> void:
	EventBus.current_phase_updated.connect(self._update_phase)
	%ButtonAccept.pressed.connect(self._accept)

	for child in %ControlGroup.get_children():
		child.count_changed.connect(self.count_changed)


func _update_phase(phase: Model.GamePhase) -> void:
	if phase != Model.GamePhase.YEAR_OF_PLENTY: self.visible = false	
	else: self.visible = true

	self._wallet.set_all(0)

	for child in %ControlGroup.get_children():
		child.reset()
		child.set_state(true, false)


func count_changed(resource: Model.ResourceTypes, count: int):
	self._wallet.set_resource(resource, count)
	
	if self._wallet.size() == 2:		
		for child in %ControlGroup.get_children():
			count = self._wallet.get_resource(child.resource)
			child.set_state(false, count > 0)

	if self._wallet.size() != 2:		
		for child in %ControlGroup.get_children():
			count = self._wallet.get_resource(child.resource)
			child.set_state(count < 2, count > 0)			


func _accept() -> void:
	EventBus.play_plenty_card.emit(Game.self_id, self._wallet)