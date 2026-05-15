extends CheckBox


func _ready():
	EventBus.current_player_updated.connect(self._current_player_updated)	
	EventBus.model_loaded.connect(func(): 
		if Game.self_id == Game.model.get_current_player(): return
		self._current_player_updated(Game.model.get_current_player())
	)

func _current_player_updated(id: int) -> void:
	if not self.button_pressed: return
	EventBus.set_player_view.emit(id)
	EventBus.model_loaded.emit()