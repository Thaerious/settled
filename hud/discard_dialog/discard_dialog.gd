class_name DiscardDialog
extends Control

@onready var RESOURSE_CONTROL_MAP: Dictionary[Model.ResourceTypes, Control] = {
		Model.ResourceTypes.BRICK: %Brick,
		Model.ResourceTypes.WOOD:  %Wood,
		Model.ResourceTypes.WHEAT: %Wheat,
		Model.ResourceTypes.ROCK:  %Rock,		
		Model.ResourceTypes.WOOL:  %Wool,
	}

@onready var _button_accept := %ButtonAccept

var bank: Wallet
var discard: Wallet
var _must_discard: int

func _ready() -> void:
	self._button_accept.pressed.connect(self._ok_pressed)
	# EventBus.current_phase_updated.connect(self._update_phase_hnd)
	# EventBus.model_loaded.connect(self._model_loaded_hnd)


func _ok_pressed() -> void:	
	EventBus.request_discard.emit(Game.self_id, discard)
	self.visible = false


func _model_loaded_hnd() -> void:
	self._update_phase_hnd(Game.model.get_current_phase())


func _update_phase_hnd(phase: Model.GamePhase) -> void:
	if phase == Model.GamePhase.DURING_DISCARD:
		self._initialize()	
	else:
		self.visible = false		


func _initialize() -> void:
	self._must_discard = Game.model.get_discard_target(Game.self_id)
	self.bank = Game.model.get_bank(Game.self_id)

	# true means I don't need to discard
	if self._must_discard >= self.bank.size():
		self.visible = false
		return		

	self.visible = true
	self._button_accept.disabled = true

	for resource in self.RESOURSE_CONTROL_MAP.keys():
		var control: DiscardResourceControl = self.RESOURSE_CONTROL_MAP[resource]		
		control.keep_qty = bank.get_resource(resource)
		control.set_disable_discard(self.bank.has_resource(resource))


func keep_resource(resource: Model.ResourceTypes) -> void:
	if discard.has_resource(resource):
		bank.add_resource(resource, 1)
		discard.remove_resource(resource, 1)
		self._on_input()	
		self._update_resource_control(resource)		


func discard_resource(resource: Model.ResourceTypes) -> void:
	if bank.has_resource(resource):
		bank.remove_resource(resource, 1)
		discard.add_resource(resource, 1)
		self._on_input()
		self._update_resource_control(resource)	


func _update_resource_control(resource: Model.ResourceTypes):
	var control: DiscardResourceControl = self.RESOURSE_CONTROL_MAP[resource]
	control.keep_qty = bank.get_resource(resource)
	control.discard_qty = discard.get_resource(resource)

	control.set_disable_keep(self.discard.has_resource(resource))
	control.set_disable_discard(self.bank.has_resource(resource))


func _on_input():
	if self.discard.size() == self._must_discard:
		self._button_accept.disabled = false
	else:
		self._button_accept.disabled = true
		
