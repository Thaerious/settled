@tool
class_name DiscardResourceControl
extends DialogControl

signal keep_resource(resource: Model.ResourceTypes)
signal discard_resource(resource: Model.ResourceTypes)

@onready var _discard_button: TextureButton = %DiscardButton
@onready var _keep_button: TextureButton = %KeepButton
@onready var _keep_qty: Label = %KeepQty
@onready var _discard_qty: Label = %DiscardQty

@export var resource: Model.ResourceTypes = Model.ResourceTypes.NONE


var keep_qty := 0:
	get: return keep_qty
	set(v): self._keep_qty.text = str(v)


var discard_qty := 0:
	get: return discard_qty
	set(v): self._discard_qty.text = str(v)


# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()

	self._keep_button.pressed.connect(func(): 
		self.keep_resource.emit(self.resource)
	)

	self._discard_button.pressed.connect(func(): 
		self.discard_resource.emit(self.resource)		
	)	

	self._keep_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	self._discard_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


func set_disable_keep(value: bool) -> void:
	self._keep_button.disabled = value


func set_disable_discard(value: bool) -> void:
	self._discard_button.disabled = value


func _on_mouse_entered() -> void:
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

func _on_mouse_exited() -> void:
	mouse_default_cursor_shape = Control.CURSOR_ARROW


func _enable() -> void:
	super._enable()
	self._discard_button.disabled = false
	self._keep_button.disabled = false


func _disable() -> void:
	super._disable()	
	self._discard_button.disabled = true
	self._keep_button.disabled = true
