class_name BasicInfoBox
extends PanelContainer


func _ready() -> void:
	EventBus.message.connect(self._on_message)


func _on_message(id: int, message: String) -> void:
	if id != -1 and id != Game.self_id: return
	self.append_text(message)	


func append_text(text: String) -> void:
	%RichTextLabel.append_text(text)
	%RichTextLabel.append_text("\n")
