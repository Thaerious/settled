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

var RESOURCE_LABEL_MAP: Dictionary[Model.ResourceTypes, Label] = {}

var tree_exchange_rate: int = 4:
	set(value):
		tree_exchange_rate = value
		if self.is_node_ready():
			self.ex_wood.text = "%s:1" % value


var tree_quantity: int = 0:
	set(value):
		tree_quantity = value
		if self.is_node_ready():
			self.qty_wood.text = "%s" % value


var wheat_exchange_rate: int = 4:
	set(value):
		wheat_exchange_rate = value
		if self.is_node_ready():
			self.ex_wheat.text = "%s:1" % value

var wheat_quantity: int = 0:
	set(value):
		wheat_quantity = value
		if self.is_node_ready():
			self.qty_wheat.text = "%s" % value


var sheep_exchange_rate: int = 4:
	set(value):
		sheep_exchange_rate = value
		if self.is_node_ready():
			self.ex_wool.text = "%s:1" % value

var sheep_quantity: int = 0:
	set(value):
		sheep_quantity = value
		if self.is_node_ready():
			self.qty_wool.text = "%s" % value


var rock_exchange_rate: int = 4:
	set(value):
		rock_exchange_rate = value
		if self.is_node_ready():
			self.ex_rock.text = "%s:1" % value

var rock_quantity: int = 0:
	set(value):
		rock_quantity = value
		if self.is_node_ready():
			self.qty_rock.text = "%s" % value


var clay_exchange_rate: int = 4:
	set(value):
		clay_exchange_rate = value
		if self.is_node_ready():
			self.ex_brick.text = "%s:1" % value

var clay_quantity: int = 0:
	set(value):
		clay_quantity = value
		if self.is_node_ready():
			self.qty_brick.text = "%s" % value


func _ready() -> void:
	self.RESOURCE_LABEL_MAP = {
		Model.ResourceTypes.BRICK: self.qty_brick,
		Model.ResourceTypes.WOOD:  self.qty_wood,
		Model.ResourceTypes.ROCK:  self.qty_rock,
		Model.ResourceTypes.WHEAT: self.qty_wheat,
		Model.ResourceTypes.WOOL:  self.qty_wool,
	}

	if self.ex_wood:
		self.ex_wood.text = "%s:1" % self.tree_exchange_rate
	if self.qty_wood:
		self.qty_wood.text = "%s" % self.tree_quantity
	if self.ex_wheat:
		self.ex_wheat.text = "%s:1" % self.wheat_exchange_rate
	if self.qty_wheat:
		self.qty_wheat.text = "%s" % self.wheat_quantity
	if self.ex_wool:
		self.ex_wool.text = "%s:1" % self.sheep_exchange_rate
	if self.qty_wool:
		self.qty_wool.text = "%s" % self.sheep_quantity
	if self.ex_rock:
		self.ex_rock.text = "%s:1" % self.rock_exchange_rate
	if self.qty_rock:
		self.qty_rock.text = "%s" % self.rock_quantity
	if self.ex_brick:
		self.ex_brick.text = "%s:1" % self.clay_exchange_rate
	if self.qty_brick:
		self.qty_brick.text = "%s" % self.clay_quantity

	EventBus.add_resources.connect(func(id: int, resources: Array) -> void:
		if id != Game.self_id: return

		for resource: Model.ResourceTypes in resources:
			var label: Label = self.RESOURCE_LABEL_MAP.get(resource)
			if label:
				label.text = str(label.text.to_int() + 1)
	)

	EventBus.remove_resources.connect(func(id: int, resources: Array) -> void:
		if id != Game.self_id: return

		for resource: Model.ResourceTypes in resources:
			var label: Label = self.RESOURCE_LABEL_MAP.get(resource)
			if label:
				label.text = str(label.text.to_int() - 1)
	)	

	EventBus.reset_view.connect(self._on_reset_view)

func _on_reset_view() -> void:
	var bank_model = Game.model.get_bank(Game.self_id)
	self.qty_brick.text = str(bank_model[Model.ResourceTypes.BRICK])
	self.qty_wood.text = str(bank_model[Model.ResourceTypes.WOOD])
	self.qty_wheat.text = str(bank_model[Model.ResourceTypes.WHEAT])
	self.qty_wool.text = str(bank_model[Model.ResourceTypes.WOOL])
	self.qty_rock.text = str(bank_model[Model.ResourceTypes.ROCK])