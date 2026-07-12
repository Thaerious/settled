@tool
class_name CardControl
extends DialogControl

func _ready() -> void:
	super._ready()
	self.clicked.connect(self._on_click)


func _on_click() -> void:
	EventBus.request_purchase_action_card.emit()
