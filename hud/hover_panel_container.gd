class_name HoverPanelContainer
extends PanelContainer


@export var normal_variation: StringName
@export var focus_variation: StringName
@export var disabled_variation: StringName

@export var enabled := true:
	get: 
		return enabled
	set(v):
		enabled = v
		if enabled:
			self.theme_type_variation = self.normal_variation
		else:
			self.theme_type_variation = self.disabled_variation



func _ready() -> void:
	self.mouse_entered.connect(self._mouse_entered)
	self.mouse_exited.connect(self._mouse_exited)

func _mouse_entered() -> void:	
	if not self.enabled: return
	self.theme_type_variation = self.focus_variation
	self.mouse_default_cursor_shape = CursorShape.CURSOR_POINTING_HAND

func _mouse_exited() -> void:
	if not self.enabled: return
	self.theme_type_variation = self.normal_variation
	self.mouse_default_cursor_shape = CursorShape.CURSOR_ARROW
