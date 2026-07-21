extends Node2D

func _on_button_2_button_up():
	%DialogSpriteControl.disabled = !%DialogSpriteControl.disabled
	print("DialogSpriteControl.disabled = %s" % [%DialogSpriteControl.disabled])

