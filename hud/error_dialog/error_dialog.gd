class_name ErrorDialog
extends DialogPane

func _ready() -> void:
	super._ready()
	%ButtonAccept.pressed.connect(self._on_accept_pressed)

	EventBus.error.connect(func(msg):				
		push_error(msg)
		self.display(msg)
	)


func display(msg: String) -> void:	
	%ContentLabel.text = msg
	self.visible = true
	self.float_to_top()


func _on_accept_pressed() -> void:
	self.visible = false
