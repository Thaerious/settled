extends Button


func _pressed():
	Game.model.load("user://savegame.json")
	EventBus.model_loaded.emit()