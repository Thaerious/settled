class_name DiscardResourceControl
extends Control

@export var resource:Model.ResourceTypes =  Model.ResourceTypes.NONE
@onready var discard_dialog: DiscardDialog = self.owner as DiscardDialog
@onready var discard_button: TextureButton = $DiscardButton
@onready var keep_button: TextureButton = $KeepButton


# Called when the node enters the scene tree for the first time.
func _ready():

	self.keep_button.pressed.connect(func(): 
		self.discard_dialog.keep_resource(self.resource)
	)

	self.discard_button.pressed.connect(func(): 
		self.discard_dialog.discard_resource(self.resource)		
	)	

	self.keep_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	self.discard_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


func _on_mouse_entered() -> void:
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

func _on_mouse_exited() -> void:
	mouse_default_cursor_shape = Control.CURSOR_ARROW
