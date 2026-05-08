extends Button


func _pressed():
	Game.model.save("user://savegame.json")

