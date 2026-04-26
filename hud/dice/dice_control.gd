class_name DiceControl
extends PanelContainer

@onready var button := %Button
@onready var die1 := %Die1
@onready var die2 := %Die2


func _ready() -> void:
	self.button.button_up.connect(func(): 
		EventBus.request_roll.emit()
	)

	EventBus.set_dice.connect(func(d1:int, d2:int):
		die1.text = str(d1)
		die2.text = str(d2)		
	);
