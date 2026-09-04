extends HBoxContainer

@onready var board = get_tree().current_scene.get_node("%GameBoard") as GameBoard

func _on_bot_button_pressed():
	if Game.model.get_current_phase() == Model.GamePhase.DISCARD:
		for i in Game.model.player_count():
			BotBasic.new(i, Game.model).process()		
	else:
		BotBasic.new(Game.model.get_current_player(), Game.model).process()


func _on_button_roll_7_pressed():
	ServiceModule._on_request_roll(4, 3)


func _on_button_clear_markers_pressed():
	EventBus.clear_targets.emit()


func _show_reachable():
	var path_builder := PathBuilder.new().run(Game.model, Game.self_id)
	var reachable:AxialSet = path_builder.visited_corners
	self.board.show_targets(reachable)


func _show_playable():
	var playable := Game.model.playable_corners()
	self.board.show_targets(playable)


func _show_reachable_intersect_playable():
	var path_builder := PathBuilder.new().run(Game.model, Game.self_id)
	var reachable := path_builder.visited_corners
	var playable := Game.model.playable_corners()
	self.board.show_targets(reachable.intersect(playable))


func _on_button_test_distance_6_pressed():
	pass # Replace with function body.


func _x():
	pass # Replace with function body.
