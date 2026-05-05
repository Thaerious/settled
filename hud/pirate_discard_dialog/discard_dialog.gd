class_name DiscardDialog
extends PanelContainer

var RESOURCE_QTY_LABEL_MAP: Dictionary[Model.ResourceTypes, Label] = {}
var RESOURCE_DIS_LABEL_MAP: Dictionary[Model.ResourceTypes, Label] = {}
var RESOURCE_TR_MAP: Dictionary[Model.ResourceTypes, TextureRect] = {}

var bank:Dictionary[Model.ResourceTypes, int]
var discard:Dictionary[Model.ResourceTypes, int]

func _ready() -> void:
	%ButtonOk.pressed.connect(func():
		EventBus.discard_resources.emit(Game.self_id, discard)
	)

	EventBus.update_player_phase.connect(self._update_player_phase_hnd)
	EventBus.reset_view.connect(self._reset_view_hnd)

	RESOURCE_QTY_LABEL_MAP = {
		Model.ResourceTypes.BRICK: %QtyBrick,
		Model.ResourceTypes.WOOD:  %QtyWood,
		Model.ResourceTypes.ROCK:  %QtyRock,
		Model.ResourceTypes.WHEAT: %QtyWheat,
		Model.ResourceTypes.WOOL:  %QtyWool,
	}

	RESOURCE_DIS_LABEL_MAP = {
		Model.ResourceTypes.BRICK: %DisBrick,
		Model.ResourceTypes.WOOD:  %DisWood,
		Model.ResourceTypes.ROCK:  %DisRock,
		Model.ResourceTypes.WHEAT: %DisWheat,
		Model.ResourceTypes.WOOL:  %DisWool,
	}

	RESOURCE_TR_MAP = {
		Model.ResourceTypes.BRICK: %BrickTexture,
		Model.ResourceTypes.WOOD:  %WoodTexture,
		Model.ResourceTypes.ROCK:  %RockTexture,
		Model.ResourceTypes.WHEAT: %WheatTexture,
		Model.ResourceTypes.WOOL:  %WoolTexture,
	}

	for resource in RESOURCE_TR_MAP.keys():
		var texture_rect = RESOURCE_TR_MAP[resource]

		texture_rect.gui_input.connect(func(event: InputEvent) -> void:
			if not event is InputEventMouseButton: return
			self._on_input(resource, event)
		)


func _reset_view_hnd() -> void:
	self._update_player_phase_hnd(Game.self_id, Game.model.get_current_phase())


func _update_player_phase_hnd(_id: int, phase: Model.GamePhase) -> void:
	if phase != Model.GamePhase.DISCARD:
		self.visible = false
	else:
		self.visible = true
		self._setup_view()


func _setup_view() -> void:
	self.bank = Game.model.get_bank(Game.self_id)
	print(bank)

	self.discard = {
		Model.ResourceTypes.BRICK: 0,
		Model.ResourceTypes.WOOD:  0,
		Model.ResourceTypes.ROCK:  0,
		Model.ResourceTypes.WHEAT: 0,
		Model.ResourceTypes.WOOL:  0,
	}

	print(self.bank)
	for resource in self.bank.keys():
		self.RESOURCE_QTY_LABEL_MAP[resource].text = str(bank[resource])


func _on_input(resource: Model.ResourceTypes, event: InputEventMouseButton):
	if not event.button_index == MouseButton.MOUSE_BUTTON_LEFT: return
	if not event.pressed: return

	if event.shift_pressed:
		if discard[resource] > 0:
			discard[resource] = discard[resource] - 1
			bank[resource] = bank[resource] + 1
	else:
		if bank[resource] > 0:
			bank[resource] = bank[resource] - 1
			discard[resource] = discard[resource] + 1
