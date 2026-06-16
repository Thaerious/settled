class_name DiscardDialog
extends Control

@onready var _button_accept := %ButtonAccept

@onready var RESOURCE_QTY_LABEL_MAP: Dictionary[Model.ResourceTypes, Label] = {
		Model.ResourceTypes.BRICK: %QtyBrick,
		Model.ResourceTypes.WOOD:  %QtyWood,
		Model.ResourceTypes.WHEAT: %QtyWheat,
		Model.ResourceTypes.ROCK:  %QtyRock,		
		Model.ResourceTypes.WOOL:  %QtyWool,
	}

@onready var RESOURCE_DIS_LABEL_MAP: Dictionary[Model.ResourceTypes, Label] = {
		Model.ResourceTypes.BRICK: %DisBrick,
		Model.ResourceTypes.WOOD:  %DisWood,
		Model.ResourceTypes.WHEAT: %DisWheat,
		Model.ResourceTypes.ROCK:  %DisRock,		
		Model.ResourceTypes.WOOL:  %DisWool,
	}

@onready var RESOURSE_CONTROL_MAP: Dictionary[Model.ResourceTypes, Control] = {
		Model.ResourceTypes.BRICK: %BrickControl,
		Model.ResourceTypes.WOOD:  %WoodControl,
		Model.ResourceTypes.WHEAT: %WheatControl,
		Model.ResourceTypes.ROCK:  %RockControl,		
		Model.ResourceTypes.WOOL:  %WoolControl,
	}

var bank: Wallet
var discard: Wallet
var _must_discard: int

func _ready() -> void:
	self._button_accept.pressed.connect(self._ok_pressed)
	EventBus.current_phase_updated.connect(self._update_phase_hnd)
	EventBus.model_loaded.connect(self._model_loaded_hnd)


func _ok_pressed() -> void:	
	EventBus.request_discard.emit(Game.self_id, discard)
	self.visible = false


func _model_loaded_hnd() -> void:
	self._update_phase_hnd(Game.model.get_current_phase())


func _update_phase_hnd(phase: Model.GamePhase) -> void:
	if phase == Model.GamePhase.DURING_DISCARD:
		self._setup_view()	
	else:
		self.visible = false		


func _setup_view() -> void:
	var target := Game.model.get_discard_target(Game.self_id)
	var count := Game.model.get_bank(Game.self_id).size()

	# true means I don't need to discard
	if target >= count:
		self.visible = false
		return		

	self.visible = true
	self._button_accept.disabled = true

	self.bank = Game.model.get_bank(Game.self_id)
	self.bank.link_view(self.RESOURCE_QTY_LABEL_MAP)

	self.discard = Wallet.new()
	self.discard.link_view(self.RESOURCE_DIS_LABEL_MAP)	
	self._must_discard = floori((self.bank.size()) / 2.0)		

	for resource in self.RESOURSE_CONTROL_MAP.keys():
		self._update_resource_control(resource)			


func _update_resource_control(resource: Model.ResourceTypes):
	var control: DiscardResourceControl = self.RESOURSE_CONTROL_MAP[resource]

	if self.bank.has_resource(resource):
		control.discard_button.disabled = false
	else:
		control.discard_button.disabled = true

	if self.discard.has_resource(resource):
		control.keep_button.disabled = false
	else:
		control.keep_button.disabled = true		


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


func _on_input():
	if self.discard.size() == self._must_discard:
		self._button_accept.disabled = false
	else:
		self._button_accept.disabled = true
		
