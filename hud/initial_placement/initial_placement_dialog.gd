extends PanelContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	EventBus.model_loaded.connect(self._on_model_updated)
	EventBus.current_phase_updated.connect(func(_1): self._on_model_updated())
	EventBus.current_player_updated.connect(func(_1): self._on_model_updated())

	%ControlHouse1.house_placed.connect(func(): 
		%ControlHouse1.disabled = true
		%ControlRoad1.disabled = false
	)
	%ControlHouse2.house_placed.connect(func(): 
		%ControlHouse2.disabled = true
		%ControlRoad2.disabled = false
	)

func _on_current_phase_updated(phase: Model.GamePhase) -> void:
	match phase:
		Model.GamePhase.SETUP: 
			self.visible = true
		_: self.visible = false	


func _on_model_updated() -> void:
	self._on_current_phase_updated(Game.model.get_current_phase())
	
	var count_houses = Game.model.get_houses(Game.self_id).size()	
	var count_roads = Game.model.get_roads(Game.self_id).size()

	%ControlHouse1.disabled = true
	%ControlRoad1.disabled = true
	%ControlHouse2.disabled = true
	%ControlRoad2.disabled = true

	if Game.model.get_current_player() != Game.self_id: return
	if Game.model.get_current_phase() != Model.GamePhase.SETUP: return

	if count_houses == 0 and count_roads == 0:
		%ControlHouse1.disabled = false
	elif count_houses == 1 and count_roads == 0:
		%ControlRoad1.disabled = false
	elif count_houses == 1 and count_roads == 1:
		%ControlHouse2.disabled = false
	elif count_houses == 2 and count_roads == 1:
		%ControlRoad2.disabled = false
	
