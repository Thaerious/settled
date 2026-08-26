class_name OKDialog
extends DialogPane

func _ready() -> void:
	super._ready()
	%ButtonAccept.pressed.connect(self._on_accept_pressed)

	EventBus.notify.connect(func(id, msg):		
		print("in OKDialog EventBus.notify.connect for %s" % [Game.self_id])
		if Game.self_id == id:
			self.display(msg)
	)


func display(msg: String) -> void:	
	%ContentLabel.text = msg
	print("in OKDialog.display")
	self.visible = true
	self.float_to_top()


func _on_accept_pressed() -> void:
	self.visible = false
