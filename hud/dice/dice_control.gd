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

	print(_button_group1.get_pressed_button())
	print(_button_group2.get_pressed_button())

	self._button_roll.button_up.connect(self._do_roll)

	EventBus.set_dice.connect(func(d1:int, d2:int):
		self._label1.text = str(d1)
		self._label2.text = str(d2)		
	);


func _do_roll() -> void:
	var button1 := _button_group1.get_pressed_button()
	var button2 := _button_group2.get_pressed_button()

	var d1: int = randi_range(1, 6)
	var d2: int = randi_range(1, 6)		

	if button1.text != "R":		
		d1 = int(button1.text)

	if button2.text != "R":		
		d2 = int(button2.text)
	
	EventBus.specify_roll.emit(d1, d2)
