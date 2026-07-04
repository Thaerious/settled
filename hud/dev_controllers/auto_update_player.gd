extends CheckBox

func _ready():
	EventBus.current_player_updated.connect(func(id: int): 
		if not self.button_pressed: return
		EventBus.set_player_view.emit(id)
	)

	EventBus.model_loaded.connect(func(): 
		if Game.self_id == Game.model.get_current_player(): return
		if not self.button_pressed: return
		EventBus.set_player_view.emit(Game.model.get_current_player())
	)
