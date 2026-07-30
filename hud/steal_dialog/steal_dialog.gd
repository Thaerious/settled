extends DialogContainer


func _ready() -> void:
	super._ready()
	visibility_changed.connect(_on_visibility_changed)

	print(%PlayerGroup)

	for p in Game.model.player_count():
		var node = %PlayerGroup.get_child(p)
		node.on_clicked.connect(
			func(): self._on_clicked(p)
		)


func _on_clicked(index: int) -> void:
	print("Click on button index %s" % index)
	

func _on_visibility_changed() -> void:
	if not self.visible: return	

	for p in Game.model.player_count():
		var record = Game.model.get_player_record(p)
		var node = %PlayerGroup.get_child(p)
		node.display_text = record.name		
