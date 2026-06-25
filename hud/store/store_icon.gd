class_name StoreIcon
extends PanelContainer

@export var theme_state_map := ThemeStateMap.new()
@onready var inner_border := self.find_child("InnerBorder", true, false) as HasThemeStateMap


@export var enabled := true:
	get: 
		return enabled
	set(v):
		enabled = v
		if enabled:
			var ib := self.inner_border as HasThemeStateMap
			if ib:
				ib.theme_state_map.apply(ib, ThemeStateMap.ThemeState.DEFAULT)
				print("after apply: %s" % self.inner_border.theme_type_variation)	
		else:
			var ib := self.inner_border as HasThemeStateMap
			if ib: 
				ib.theme_state_map.apply(ib, ThemeStateMap.ThemeState.DISABLED)	
				print("after apply: %s" % self.inner_border.theme_type_variation)	

			
		


func _ready() -> void:
	self.enabled = self.enabled
	self.mouse_entered.connect(self._mouse_entered)
	self.mouse_exited.connect(self._mouse_exited)

	print("A ", self.find_child("InnerBorder", true, false))
	print("B ", self.find_child("InnerBorder", true, false) is HasThemeStateMap)


func _mouse_entered() -> void:	
	if not self.enabled: return
	self.theme_state_map.apply(self, ThemeStateMap.ThemeState.HOVER)
	self.mouse_default_cursor_shape = CursorShape.CURSOR_POINTING_HAND

	var ib := self.inner_border as HasThemeStateMap
	if ib: ib.theme_state_map.apply(ib, ThemeStateMap.ThemeState.HOVER)	


func _mouse_exited() -> void:
	if not self.enabled: return
	self.theme_state_map.apply(self, ThemeStateMap.ThemeState.DEFAULT)
	self.mouse_default_cursor_shape = CursorShape.CURSOR_ARROW

	self.inner_border.theme_state_map.apply(self.inner_border, ThemeStateMap.ThemeState.DEFAULT)	
