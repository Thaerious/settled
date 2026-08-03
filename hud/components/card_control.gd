@tool
extends DialogSpriteControl


func _ready() -> void:
	super._ready()


func _on_clicked() -> void:
	print("on clicked card control")
	EventBus.request_purchase_action_card.emit()
