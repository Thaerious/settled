class_name DiceControl
extends PanelContainer

@onready var button := %Button
@onready var die1 := %Die1
@onready var die2 := %Die2


func _ready() -> void:
	self.button.button_up.connect(self.on_button_up)	


func on_button_up() -> void:
	var d1 := randi_range(1, 6)
	var d2 := randi_range(1, 6)
	die1.text = str(d1)
	die2.text = str(d2)
	EventBus.set_roll.emit(d1, d2)
