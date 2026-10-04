# filename: dev_controllers/dev_controller.gd
extends HBoxContainer

@onready var board = get_tree().current_scene.get_node("%GameBoard") as GameBoard
@onready var ok_dialog = get_tree().current_scene.get_node("%OkDialog") as OkDialog

var _client: Client = null

func _on_button_roll_7_pressed():
	ServiceModule._on_request_roll(4, 3)


func _connect_to_server():
	self._client = Client.new()
	self._client.connect_to_server(9999)


func _on_bot_button_pressed():
	ModelLoader.save(Game.model, "user://_backup.json")
	ok_dialog.visible = false

	ModelLoader.save(Game.model, "user://_backup.json")
	ok_dialog.visible = false

	var data = ModelLoader.encode(Game.model)
	self._client.writer.send_packet("model", data)
