class_name DiceControl
extends PanelContainer


@onready var _button_roll := %ButtonRoll
@onready var _label1 := %Label1
@onready var _label2 := %Label2

var _button_group1: ButtonGroup
var _button_group2: ButtonGroup


func _ready() -> void:
	_button_group1 = %Die1CB1.button_group
	_button_group2 = %Die2CB1.button_group

	_button_group1.get_buttons()[6].button_pressed = true
	_button_group2.get_buttons()[6].button_pressed = true	

	self._button_roll.button_up.connect(self.do_roll)

	EventBus.dice_set.connect(func(d1, d2):
		self._label1.text = str(d1)
		self._label2.text = str(d2)
	)

func get_dice() -> Array:
	var button1 := _button_group1.get_pressed_button()
	var button2 := _button_group2.get_pressed_button()
	var txt1 = button1.text
	var txt2 = button2.text
	var die1 = -1
	var die2 = -1
	if txt1 != "R": die1 = int(txt1)
	if txt2 != "R": die2 = int(txt2)
	return [die1, die2]


func do_roll() -> void:
	EventBus.request_roll.emit()
