@tool
class_name PlentyDialogSpriteControl
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
		self._check_state()
	)

	%ButtonDn.pressed.connect(func():
		if self.count <= 0: return
		self.count = self.count - 1
		%Qty.text = str(self.count)
		self.count_changed.emit(self.resource, self.count)
		self._check_state()
	)


func _check_state() -> void:
	if self.count >= 2: %ButtonUp.disabled = true
	else: %ButtonUp.disabled = false
	if self.count <= 0: %ButtonDn.disabled = true
	else: %ButtonDn.disabled = false


func reset() -> void:
	self.count = 0
	%Qty.text = str(self.count)
	self._check_state()
