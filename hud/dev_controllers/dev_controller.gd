extends HBoxContainer

func _on_bot_button_pressed():
	print("_on_bot_button_pressed")
	Game.do_bot_action(Game.self_id)


func _on_button_test_pressed():
	var edges = Game.model.playable_edges(Game.self_id)
	for edge in edges:
		
