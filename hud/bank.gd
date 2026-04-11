## bank.gd
@tool
class_name Bank
extends PanelContainer

@onready var ex_tree: Label = %ExTree
@onready var qty_tree: Label = %QtyTree
@onready var ex_wheat: Label = %ExWheat
@onready var qty_wheat: Label = %QtyWheat
@onready var ex_sheep: Label = %ExSheep
@onready var qty_sheep: Label = %QtySheep
@onready var ex_rock: Label = %ExRock
@onready var qty_rock: Label = %QtyRock
@onready var ex_clay: Label = %ExClay
@onready var qty_clay: Label = %QtyClay


var tree_exchange_rate: int = 4:
	set(value):
		tree_exchange_rate = value
		if self.is_node_ready():
			self.ex_tree.text = "%s:1" % value

var tree_quantity: int = 0:
	set(value):
		tree_quantity = value
		if self.is_node_ready():
			self.qty_tree.text = "%s" % value


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
			self.ex_sheep.text = "%s:1" % value

var sheep_quantity: int = 0:
	set(value):
		sheep_quantity = value
		if self.is_node_ready():
			self.qty_sheep.text = "%s" % value


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
			self.ex_clay.text = "%s:1" % value

var clay_quantity: int = 0:
	set(value):
		clay_quantity = value
		if self.is_node_ready():
			self.qty_clay.text = "%s" % value


func _ready() -> void:
	if self.ex_tree:
		self.ex_tree.text = "%s:1" % self.tree_exchange_rate
	if self.qty_tree:
		self.qty_tree.text = "%s" % self.tree_quantity
	if self.ex_wheat:
		self.ex_wheat.text = "%s:1" % self.wheat_exchange_rate
	if self.qty_wheat:
		self.qty_wheat.text = "%s" % self.wheat_quantity
	if self.ex_sheep:
		self.ex_sheep.text = "%s:1" % self.sheep_exchange_rate
	if self.qty_sheep:
		self.qty_sheep.text = "%s" % self.sheep_quantity
	if self.ex_rock:
		self.ex_rock.text = "%s:1" % self.rock_exchange_rate
	if self.qty_rock:
		self.qty_rock.text = "%s" % self.rock_quantity
	if self.ex_clay:
		self.ex_clay.text = "%s:1" % self.clay_exchange_rate
	if self.qty_clay:
		self.qty_clay.text = "%s" % self.clay_quantity
