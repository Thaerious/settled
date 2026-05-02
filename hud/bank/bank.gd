## bank.gd
@tool
class_name Bank
extends PanelContainer

@onready var ex_wood: Label = %ExWood
@onready var qty_wood: Label = %QtyWood
@onready var ex_wheat: Label = %ExWheat
@onready var qty_wheat: Label = %QtyWheat
@onready var ex_wool: Label = %ExWool
@onready var qty_wool: Label = %QtyWool
@onready var ex_rock: Label = %ExRock
@onready var qty_rock: Label = %QtyRock
@onready var ex_brick: Label = %ExBrick
@onready var qty_brick: Label = %QtyBrick

var RESOURCE_QTY_LABEL_MAP: Dictionary[Model.ResourceTypes, Label] = {}
var RESOURCE_EX_LABEL_MAP: Dictionary[Model.ResourceTypes, Label] = {}


func _ready() -> void:
	self.RESOURCE_QTY_LABEL_MAP = {
		Model.ResourceTypes.BRICK: self.qty_brick,
		Model.ResourceTypes.WOOD:  self.qty_wood,
		Model.ResourceTypes.ROCK:  self.qty_rock,
		Model.ResourceTypes.WHEAT: self.qty_wheat,
		Model.ResourceTypes.WOOL:  self.qty_wool,
	}

	self.RESOURCE_EX_LABEL_MAP = {
		Model.ResourceTypes.BRICK: self.ex_brick,
		Model.ResourceTypes.WOOD:  self.ex_wood,
		Model.ResourceTypes.ROCK:  self.ex_rock,
		Model.ResourceTypes.WHEAT: self.ex_wheat,
		Model.ResourceTypes.WOOL:  self.ex_wool,
	}

	EventBus.add_resources.connect(func(id: int, resources: Array) -> void:
		if id != Game.self_id: return

		for resource: Model.ResourceTypes in resources:
			var label: Label = self.RESOURCE_QTY_LABEL_MAP.get(resource)
			if label:
				label.text = str(label.text.to_int() + 1)
	)

	EventBus.remove_resources.connect(func(id: int, resources: Array) -> void:
		if id != Game.self_id: return

		for resource: Model.ResourceTypes in resources:
			var label: Label = self.RESOURCE_QTY_LABEL_MAP.get(resource)
			if label:
				label.text = str(label.text.to_int() - 1)
	)	

	EventBus.set_exchange_rate.connect(func(id: int, r: Model.ResourceTypes, value: int) -> void:
		if id != Game.self_id: return
		RESOURCE_EX_LABEL_MAP[r].text = "%s:1" % value		
	)

	EventBus.reset_view.connect(self._on_reset_view)


func _on_reset_view() -> void:
	var bank_model = Game.model.get_bank(Game.self_id)

	for r:Model.ResourceTypes in Service.EXCHANGABLE:
		RESOURCE_QTY_LABEL_MAP[r].text = str(bank_model[r])
		RESOURCE_EX_LABEL_MAP[r].text = "%s:1" % Game.model.get_exchange_rate(Game.self_id, r)	
