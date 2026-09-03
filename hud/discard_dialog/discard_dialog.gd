@tool
class_name DiscardDialog
extends DialogFrame

var _wallet = Wallet.new()
var _target = 0

func _ready() -> void:
	super._ready()

	EventBus.current_phase_updated.connect(self._update_phase)
	EventBus.resources_updated.connect(func(_1, _2): 
		self._update_phase(Game.model.get_current_phase())
	)

	%ButtonAccept.pressed.connect(self._accept)

	for child in %ControlGroup.get_children():
		child.count_changed.connect(self.count_changed)


func _update_phase(phase: Model.GamePhase) -> void:
	self._target = Game.model.get_discard_target(Game.self_id)
	self.visible = false

	if phase != Model.GamePhase.DISCARD: return

	if self._target <= 0:
		EventBus.notify.emit(Game.self_id, "Waiting for players to discard")
		return

	self.visible = true
	self.float_to_top()
	%Title.text = "Discard %s Resources" % self._target
	%ButtonAccept.disabled = true	

	self._wallet.set_all(0)
	var resources = Game.model.get_bank(Game.self_id)

	for child in %ControlGroup.get_children():
		child.reset()
		var allow_up = resources.get_resource(child.resource)
		child.set_state(allow_up, false)		


func count_changed(resource: Model.ResourceTypes, count: int):
	var resources = Game.model.get_bank(Game.self_id)		
	self._wallet.set_resource(resource, count)
	
	if self._wallet.sum() == self._target:		
		for child in %ControlGroup.get_children():
			count = self._wallet.get_resource(child.resource)
			child.set_state(false, count > 0)
			%ButtonAccept.disabled = false
	else:
		for child in %ControlGroup.get_children():
			count = self._wallet.get_resource(child.resource)
			var allow_up = resources.get_resource(child.resource) > count
			child.set_state(allow_up, count > 0)
			%ButtonAccept.disabled = true		


func _accept() -> void:
	print(self._wallet)
	EventBus.request_discard.emit(Game.self_id, self._wallet)
