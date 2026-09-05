extends HBoxContainer

@onready var board = get_tree().current_scene.get_node("%GameBoard") as GameBoard
var _last = null

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


func _show_building_ranks():
	var axials = []
	var bot = BotBasic.new(Game.self_id, Game.model)
	bot.process()

	var building_ranks = bot.rank_buildings()
	for string in building_ranks:
		axials.append(string)

	for target in self.board.show_targets(axials):
		target.area_2d.input_event.connect(func(_1, _2, _3): 
			if self._last == target: return
			print(" - %s %s %s" % [target.get_script().get_global_name(), target.axial, building_ranks[target.axial.key()]])
			target.modulate = Color.RED
			if self._last != null: self._last.modulate = Color.WHITE
			self._last = target
		)
