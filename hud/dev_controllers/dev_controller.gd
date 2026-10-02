# filename: dev_controllers/dev_controller.gd
extends HBoxContainer

@onready var board = get_tree().current_scene.get_node("%GameBoard") as GameBoard
@onready var ok_dialog = get_tree().current_scene.get_node("%OkDialog") as OkDialog
var _last = null

func _on_bot_button_pressed():
	# if not Python.is_launched: Python.launch_server(9999)

	if not Python.is_server_connected: 
		await Python.connect_to_server(9999)
		print("Connected to server")

	ModelLoader.save(Game.model, "user://_backup.json")
	ok_dialog.visible = false

	ModelLoader.save(Game.model, "user://_backup.json")
	ok_dialog.visible = false

	if Game.model.get_current_phase() == Model.GamePhase.DISCARD:
		for i in Game.model.player_count():
			self._send_model()
	else:
		self._send_model()


func _send_model():
	var encoded_model = ModelLoader.encode(Game.model)
	Python.send_packet("model", encoded_model)
	var resp = await Python.read_response()

	if not resp is Dictionary:
		push_error("bad or no response: %s" % [resp])
		return

	print("Server Response | packet: %s" % [resp])

	if resp.get("action_type") != "decision":
		push_error("unexpected packet: %s" % resp.get("action"))
		return

	DoBotAction.run(resp["data"])


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

	for string in bot.rank_all():
		axials.append(string)

	for target in self.board.show_targets(axials):
		target.area_2d.input_event.connect(
			func(_v, event, _s): self._on_target_click(target, event, bot)
		)

func _on_target_click(target: Node2D, event: InputEvent, bot: BotBasic) -> void:
	if not event is InputEventMouseButton: return
	if not event.button_index == MouseButton.MOUSE_BUTTON_LEFT: return
	if not event.is_pressed(): return
	print(" - %s %s %s" % [target.get_script().get_global_name(), target.axial, bot.ranks[target.axial.key()]])
	target.modulate = Color.RED

	if self._last != null:
		self._last.modulate = Color.WHITE

	self._last = target


func _on_estimate_house() -> void:
	var est = TimeEstimator.new(Game.self_id, Game.model)	

	var house_road = Model.COSTS["road"].duplicate().add_resources(Model.COSTS["house"])

	print("A house will take ~%s turns to afford" % [est.estimate(Model.COSTS["house"])])
	print("A road will take ~%s turns to afford" % [est.estimate(Model.COSTS["road"])])
	print("A house + road will take ~%s turns to afford" % [est.estimate(house_road)])
	print("A city will take ~%s turns to afford" % [est.estimate(Model.COSTS["city"])])
	print("A card will take ~%s turns to afford" % [est.estimate(Model.COSTS["card"])])

func _exchange_for_house() -> void:
	print("exchange house %s" % Bot.do_exchange(Game.self_id, Game.model, Model.COSTS["house"]))

func _exchange_for_city() -> void:
	print("exchange city %s" % Bot.do_exchange(Game.self_id, Game.model, Model.COSTS["city"]))

func _exchange_for_road() -> void:
	print("exchange road %s" % Bot.do_exchange(Game.self_id, Game.model, Model.COSTS["road"]))

func _exchange_for_card() -> void:
	print("exchange card %s" % Bot.do_exchange(Game.self_id, Game.model, Model.COSTS["card"]))			

func _launch_python_server():
	Python.launch_server(9999)
