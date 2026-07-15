extends DialogContainer

func _ready() -> void:
	super._ready()

	EventBus.road_added.connect(func(_id: int, _edge: AxialEdge):
		self._update_controls()
	)


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


func _on_current_phase_updated(phase: Model.GamePhase) -> void:
	self._update_controls()

	match phase:
		Model.GamePhase.ROAD_BUILDING: 
			self.visible = true
		_: self.visible = false	
