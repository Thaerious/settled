extends DialogFrame


# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	EventBus.model_loaded.connect(self._on_model_loaded)
	EventBus.current_phase_updated.connect(self._on_current_phase_updated)
	EventBus.current_player_updated.connect(func(_1): self._on_model_loaded())
	EventBus.house_added.connect(func(_1, _2): self._on_model_loaded())
	EventBus.road_added.connect(func(_1, _2): self._on_model_loaded())


func _on_current_phase_updated(phase: Model.GamePhase) -> void:
	match phase:
		Model.GamePhase.SETUP:
			self.visible = true
			self._on_model_loaded()
		_: self.visible = false


func _on_model_loaded() -> void:
	if Game.model.get_current_player() != Game.self_id: return

	%HouseControl1.disabled = true
	%RoadControl1.disabled = true
	%HouseControl2.disabled = true
	%RoadControl2.disabled = true

	match Game.model.get_placement_phase(Game.self_id):
		Model.PlacementPhase.HOUSE1: %HouseControl1.disabled = false
		Model.PlacementPhase.ROAD1:  %RoadControl1.disabled = false
		Model.PlacementPhase.HOUSE2: %HouseControl2.disabled = false
		Model.PlacementPhase.ROAD2:  %RoadControl2.disabled = false		