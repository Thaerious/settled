extends DialogFrame

func _ready() -> void:
	super._ready()

	EventBus.road_added.connect(func(_id: int, _edge: AxialEdge):
		self._update_controls()
	)

	self.visibility_changed.connect(self._update_controls)	
	EventBus.current_phase_updated.connect(func(_1): self._update_controls())


func _update_controls():
	if Game.model.free_road_count() == 0:
		%FreeRoadControl1.disabled = true
		%FreeRoadControl2.disabled = true
	elif Game.model.free_road_count() <= 1:
		%FreeRoadControl1.disabled = true
		%FreeRoadControl2.disabled = false
	else:
		%FreeRoadControl1.disabled = false
		%FreeRoadControl2.disabled = false
