# filename: screens/game_screen.gd
extends Node2D


var alt_text := false


func _unhandled_key_input(event: InputEvent):
	if event is InputEventKey and event.keycode == KEY_ALT:		
		if event.pressed: 
			if self.alt_text: return
			self.alt_text = true
			%HandDialog.alt_text = true
			%StoreDialog.alt_text = true
		else:
			if not self.alt_text: return
			self.alt_text = false
			%HandDialog.alt_text = false
			%StoreDialog.alt_text = false
