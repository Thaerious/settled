class_name DiscardDialog
extends PanelContainer

@onready var _main_container := %MainContainer
@onready var _pending_label := %PendingLabel
@onready var _button_ok := %ButtonOk

@onready var RESOURCE_QTY_LABEL_MAP: Dictionary[Model.ResourceTypes, Label] = {
		Model.ResourceTypes.BRICK: %QtyBrick,
		Model.ResourceTypes.WOOD:  %QtyWood,
		Model.ResourceTypes.ROCK:  %QtyRock,
		Model.ResourceTypes.WHEAT: %QtyWheat,
		Model.ResourceTypes.WOOL:  %QtyWool,
	}

@onready var RESOURCE_DIS_LABEL_MAP: Dictionary[Model.ResourceTypes, Label] = {
		Model.ResourceTypes.BRICK: %DisBrick,
		Model.ResourceTypes.WOOD:  %DisWood,
		Model.ResourceTypes.ROCK:  %DisRock,
		Model.ResourceTypes.WHEAT: %DisWheat,
		Model.ResourceTypes.WOOL:  %DisWool,
	}

@onready var RESOURCE_TEXTURE_MAP: Dictionary[Model.ResourceTypes, TextureRect] = {
		Model.ResourceTypes.BRICK: %BrickTexture,
		Model.ResourceTypes.WOOD:  %WoodTexture,
		Model.ResourceTypes.ROCK:  %RockTexture,
		Model.ResourceTypes.WHEAT: %WheatTexture,
		Model.ResourceTypes.WOOL:  %WoolTexture,
	}

var bank: Wallet
var discard: Wallet
var _must_discard: int

func _ready() -> void:
	self._button_ok.pressed.connect(self._ok_pressed)

	EventBus.phase_updated.connect(self._update_phase_hnd)
	EventBus.model_loaded.connect(self._model_loaded_hnd)

	for r in RESOURCE_TEXTURE_MAP.keys():
		var texture_rect = self.RESOURCE_TEXTURE_MAP[r]
		texture_rect.gui_input.connect(func(event: InputEvent) -> void:
			if not event is InputEventMouseButton: return
			self._on_input(r, event)
		)	


func _ok_pressed() -> void:	
	EventBus.discard_resources.emit(Game.self_id, discard)
	self._main_container.visible = false
	self._pending_label.visible = true


func _model_loaded_hnd() -> void:
	self._update_phase_hnd(Game.model.get_current_phase())


func _update_phase_hnd(phase: Model.GamePhase) -> void:
	if phase != Model.GamePhase.DURING_DISCARD:
		self.visible = false
	else:
		self.visible = true
		self._setup_view()


func _setup_view() -> void:
	var discarded := Game.model.get_discarded()
	
	# false means I don't need to discard
	if not discarded[Game.self_id]:
		self._main_container.visible = false
		self._pending_label.visible = true
		return		

	self._main_container.visible = true
	self._pending_label.visible = false		
	self._button_ok.disabled = true

	self.bank = Game.model.get_bank(Game.self_id)
	self.bank.link_view(self.RESOURCE_QTY_LABEL_MAP)

	self.discard = Wallet.new()
	self.discard.link_view(self.RESOURCE_DIS_LABEL_MAP)	
	self._must_discard = ceili((self.bank.count_resources() - 7.0) / 2.0)		


func _on_input(resource: Model.ResourceTypes, event: InputEventMouseButton):
	if not event.button_index == MouseButton.MOUSE_BUTTON_LEFT: return
	if not event.pressed: return

	if event.shift_pressed:
		if discard.has_resource(resource):
			discard.add_resource(resource, -1)			
			bank.add_resource(resource, 1)			
	else:
		if bank.get_resource(resource) > 0:
			bank.add_resource(resource, -1)
			discard.add_resource(resource, 1)
	
	if self.discard.count_resources() == self._must_discard:
		self._button_ok.disabled = false
	else:
		self._button_ok.disabled = true
		