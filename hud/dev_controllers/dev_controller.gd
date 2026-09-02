extends HBoxContainer

@onready var board = get_tree().current_scene.get_node("%GameBoard") as GameBoard

func _on_bot_button_pressed():
	if Game.model.get_current_phase() == Model.GamePhase.DISCARD:
		for i in Game.model.player_count():
			BotBasic.new(i, Game.model).process()		
	else:
		BotBasic.new(Game.model.get_current_player(), Game.model).process()


func _on_button_test_edges_pressed():
	EventBus.clear_targets.emit()
	var edges = Game.model.playable_edges()

	for pid in range(0, Game.player_count):
		if pid == Game.self_id: continue
		var houses = Game.model.get_all_buildings(pid)
		edges = edges.difference(houses.edge_map())

	self.board.show_targets(edges)
	

func _on_button_test_corners_pressed():
	EventBus.clear_targets.emit()
	var corners = Game.model.playable_corners()
	self.board.show_targets(corners)


func _on_button_test_ends():
	var edges = Game.model.get_roads(Game.self_id)
	
	for pid in range(0, Game.player_count):
		if pid == Game.self_id: continue
		var houses = Game.model.get_all_buildings(pid)
		edges = edges.difference(houses.edge_map())
	
	self.board.show_targets(edges.corner_map())


func _on_button_roll_7_pressed():
	ServiceModule._on_request_roll(4, 3)


func on_button_show_valid_corners_pressed():
	var valid_corners = Game.model.valid_corners()
	self.board.show_targets(valid_corners)


func on_button_show_playable_corners_pressed():
	var playable = Game.model.playable_corners()
	self.board.show_targets(playable)


func _on_button_test_path_builder_pressed():
	var path_builder := PathBuilder.new().run(Game.model, Game.self_id)
	
	var corners := path_builder.visited_corners.intersect(Game.model.playable_corners())
	var nodes = self.board.show_targets(corners)

	for target in nodes: 
		target.modulate = Color.BLUE
	

	
	# for target in board.show_targets(corners): target.modulate = Color.YELLOW

	# for target in targets:
	# 	target.get_node("%Area2D").mouse_entered.connect(func():
	# 		print("Distance to %s = %d" % [target.axial, path_builder.distances[target.axial.key()]])
	# 	)


# func _rank_house() -> Array[Variant]:
# 	print("Rank House")
# 	var best_rank = -INF
# 	var best_axial = null

	# Evaluate each valid corner that can accept a house
	# var corners := Game.model.playable_corners()
	# for corner in corners:
	# 	var rank = self.rank_corner(corner)
	# 	if not self.path_builder.distances.values().has(corner.key()): continue
	# 	var distance = self.path_builder.distances[corner.key()]
	# 	rank = rank + self.distance_weight(distance)

	# 	if rank > best_rank:
	# 		best_rank = rank
	# 		best_axial = corner
	# 		print("[%s, %s, %s]" % [best_rank, "house", best_axial])

	# var best_distance = self.path_builder.distances[best_axial.key()]

	# if best_distance == 0:
	# 	return [best_rank, "house", best_axial]
	# else:
	# 	var path = self.path_builder.paths[best_axial.key()]
	# 	return [best_rank, "road", path[0]]


func _on_button_clear_markers_pressed():
	EventBus.clear_targets.emit()


func _on_button_show_player_corners_pressed():
	var playable = Game.model.playable_corners(Game.self_id)
	self.board.show_targets(playable)
