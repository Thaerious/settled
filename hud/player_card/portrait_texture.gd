class_name PortraitTexture
extends TextureRect

func _on_clicked():
	EventBus.set_player_view.emit(self.owner.player_id)
	EventBus.model_loaded.emit()
	EventBus.current_phase_updated.emit(Game.model.get_current_phase())
	EventBus.current_player_updated.emit(Game.model.get_current_player())	
