@tool
class_name DiscardDialog
extends DialogContainer

var _wallet = Wallet.new()

func _ready() -> void:
	EventBus.current_phase_updated.connect(self._update_phase)
	%ButtonAccept.pressed.connect(self._accept)

	for child in %ControlGroup.get_children():
		child.count_changed.connect(self.count_changed)


func _update_phase(phase: Model.GamePhase) -> void:
	var target = Game.model.get_discard_target(Game.self_id)

	if phase != Model.GamePhase.DURING_DISCARD or target < 0: 
		self.visible = false	
		return
	else: 
		self.visible = true
		%Title.text = "Discard to %s" % target	
		%ButtonAccept.disabled = true	

	self._wallet.set_all(0)
	var resources = Game.model.get_bank(Game.self_id)

	for child in %ControlGroup.get_children():
		child.reset()
		var allow_up = resources.get_resource(child.resource)
		child.set_state(allow_up, false)
		


func count_changed(resource: Model.ResourceTypes, count: int):
	var target = Game.model.get_discard_target(Game.self_id)
	var resources = Game.model.get_bank(Game.self_id)	
	self._wallet.set_resource(resource, count)
	
	if self._wallet.size() == target:		
		for child in %ControlGroup.get_children():
			count = self._wallet.get_resource(child.resource)
			child.set_state(false, count > 0)
			%ButtonAccept.disabled = false

	if self._wallet.size() != target:		
		for child in %ControlGroup.get_children():
			count = self._wallet.get_resource(child.resource)
			var allow_up = resources.get_resource(child.resource) > count
			child.set_state(allow_up, count > 0)
			%ButtonAccept.disabled = true		


func _accept() -> void:
	EventBus.request_discard.emit(Game.self_id, self._wallet)
