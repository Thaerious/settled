class_name StoreIcon
extends PanelContainer

@export var theme_state_map := ThemeStateMap.new()
@onready var inner_border :HasThemeStateMap 


@export var enabled := true:
	get: 
		return enabled
	set(v):
		enabled = v
		if enabled:
			self.theme_state_map.apply(self, ThemeStateMap.ThemeState.DEFAULT)
			if self.inner_border:
				self.inner_border.theme_state_map.apply(self.inner_border, ThemeStateMap.ThemeState.DEFAULT)		
		else:
			self.theme_state_map.apply(self, ThemeStateMap.ThemeState.DISABLED)
			if self.inner_border:
				self.inner_border.theme_state_map.apply(self.inner_border, ThemeStateMap.ThemeState.DISABLED)

			
		


func _ready() -> void:
	self.mouse_entered.connect(self._mouse_entered)
	self.mouse_exited.connect(self._mouse_exited)
	self.inner_border = self.find_child("InnerBorder", true, false) as HasThemeStateMap
	self.enabled = self.enabled

func _mouse_entered() -> void:	
	if not self.enabled: return
	self.theme_state_map.apply(self, ThemeStateMap.ThemeState.HOVER)
	self.mouse_default_cursor_shape = CursorShape.CURSOR_POINTING_HAND
	self.inner_border.theme_state_map.apply(self.inner_border, ThemeStateMap.ThemeState.HOVER)	


func _mouse_exited() -> void:
	if not self.enabled: return
	self.theme_state_map.apply(self, ThemeStateMap.ThemeState.DEFAULT)
	self.mouse_default_cursor_shape = CursorShape.CURSOR_ARROW
	self.inner_border.theme_state_map.apply(self.inner_border, ThemeStateMap.ThemeState.DEFAULT)	
