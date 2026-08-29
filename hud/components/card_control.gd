@tool
extends DialogSpriteControl


func _ready() -> void:
	super._ready()


func _on_clicked() -> void:
	EventBus.request_purchase_action_card.emit(Game.self_id)
