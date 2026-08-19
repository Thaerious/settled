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
	print("Initial Placement Dialog on model loaded")
	var count_houses = Game.model.get_houses(Game.self_id).size()
	var count_roads = Game.model.get_roads(Game.self_id).size()

	%HouseControl1.disabled = true
	%RoadControl1.disabled = true
	%HouseControl2.disabled = true
	%RoadControl2.disabled = true

	if Game.model.get_current_player() != Game.self_id: return
	if Game.model.get_current_phase() != Model.GamePhase.SETUP: return

	print("Houses, Roads: %s %s" % [count_houses, count_roads])

	if count_houses == 0 and count_roads == 0:
		%HouseControl1.disabled = false
	elif count_houses == 1 and count_roads == 0:
		%RoadControl1.disabled = false
	elif count_houses == 1 and count_roads == 1:
		%HouseControl2.disabled = false
	elif count_houses == 2 and count_roads == 1:
		%RoadControl2.disabled = false
