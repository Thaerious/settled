extends Button



func _pressed():
	Game.model.load("user://savegame.json")
	EventBus.reset_view.emit()