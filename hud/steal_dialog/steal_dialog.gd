extends DialogFrame


func _ready() -> void:
	super._ready()
	EventBus.model_loaded.connect(self._on_visibility_changed)
	visibility_changed.connect(_on_visibility_changed)

	for p in Game.model.player_count():
		var node = %PlayerGroup.get_child(p)
		node.on_clicked.connect(
			func(): self._on_clicked(p)
		)


func _on_clicked(index: int) -> void:
	EventBus.request_steal_from.emit(index)
	

func _on_visibility_changed() -> void:
	if not self.visible: return	

	var child_nodes = %PlayerGroup.get_children()
	var pirate_axial: Axial = Game.model.get_pirate()
	var corners = pirate_axial.corners()	

	for p in Game.model.player_count():
		child_nodes[p].disabled = true

		var buildings = Game.model.get_all_buildings(p)
		var intersect = buildings.intersect(corners)	
		
		if intersect.size() == 0 or p == Game.self_id:
			child_nodes[p].disabled = true
		else:
			child_nodes[p].disabled = false

		var record = Game.model.get_player_record(p)
		var node = %PlayerGroup.get_child(p)
		var resource_count = Game.model.count_resources(p)
		node.display_text = "%s [%s]" % [record.name, resource_count]
