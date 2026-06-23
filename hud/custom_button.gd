class_name CustomButton
extends Button


func _set(pname, value):
	match pname:
		"disabled":
			if value:
				self.mouse_default_cursor_shape  = CursorShape.CURSOR_ARROW
			else:
				self.mouse_default_cursor_shape  = CursorShape.CURSOR_POINTING_HAND			
			disabled = value
