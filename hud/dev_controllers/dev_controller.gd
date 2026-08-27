extends HBoxContainer


func _on_bot_button_pressed():
	Game.do_bot_action(Game.self_id)


func _on_button_test_edges_pressed():
	EventBus.clear_targets.emit()
	var board = get_tree().current_scene.get_node("%GameBoard") as GameBoard
	var edges = Game.model.playable_edges()

	for pid in range(0, Game.player_count):
		if pid == Game.self_id: continue
		var houses = Game.model.get_all_buildings(pid)
		edges = edges.difference(houses.edge_map())

	board.show_targets(edges)
	

func _on_button_test_corners_pressed():
	EventBus.clear_targets.emit()
	var board = get_tree().current_scene.get_node("%GameBoard") as GameBoard
	var corners = Game.model.playable_corners()
	board.show_targets(corners)


func _on_button_test_ends():
	var edges = Game.model.get_roads(Game.self_id)
	
	for pid in range(0, Game.player_count):
		if pid == Game.self_id: continue
		var houses = Game.model.get_all_buildings(pid)
		edges = edges.difference(houses.edge_map())
	
	var board = get_tree().current_scene.get_node("%GameBoard") as GameBoard
	board.show_targets(edges.corner_map())


func _on_button_test_distance_pressed():
	var path_builder := PathBuilder.new().run(Game.model, Game.self_id)
	var board = get_tree().current_scene.get_node("%GameBoard") as GameBoard
	var targets = board.show_targets(path_builder.corners)


	for target in targets:
		target.get_node("%Area2D").mouse_entered.connect(func():
			print("Distance to %s = %d" % [target.axial, path_builder.distances[target.axial.key()]])
		)


func _on_button_roll_7_pressed():
	ServiceModule._on_request_roll(4, 3)
