extends HBoxContainer

func _on_bot_button_pressed():
	print("_on_bot_button_pressed")
	Game.do_bot_action(Game.self_id)
