@tool
class_name PlentyDialogControl
extends DialogSpriteControl

signal count_changed(resource: Model.ResourceTypes, count: int)
@export var resource := Model.ResourceTypes.NONE
var count := 0

func _ready() -> void:
	super._ready()	

	%ButtonUp.pressed.connect(func():
		if self.count >= 2: return
		self.count = self.count + 1
		%Qty.text = str(self.count)
		self.count_changed.emit(self.resource, self.count)
	)

	%ButtonDn.pressed.connect(func():
		if self.count <= 0: return
		self.count = self.count - 1
		%Qty.text = str(self.count)
		self.count_changed.emit(self.resource, self.count)
	)


func set_state(allow_up: bool, allow_down: bool) -> void:
	if allow_up: %ButtonUp.disabled = false
	else: %ButtonUp.disabled = true
	if allow_down: %ButtonDn.disabled = false
	else: %ButtonDn.disabled = true


func reset() -> void:
	self.count = 0
	%Qty.text = str(self.count)
