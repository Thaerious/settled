class_name PortraitTexture
extends TextureRect

func _on_clicked():
	EventBus.set_player_view.emit(self.owner.player_id)
	EventBus.model_loaded.emit()
