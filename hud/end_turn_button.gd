extends Button

@onready var dice: DiceControl = %Dice


func _ready():
	EventBus.current_phase_updated.connect(self._current_phase_updated)	
	EventBus.model_loaded.connect(self._model_loaded)


func _model_loaded() -> void:
	self._current_phase_updated(Game.model.get_current_phase())


func _current_phase_updated(phase: Model.GamePhase) -> void:
	if phase == Model.GamePhase.MAIN and Game.model.get_current_player() == Game.self_id:
		self.disabled = false
	else:
		self.disabled = true

	
func _pressed() -> void:
	EventBus.request_end_turn.emit()
	dice.do_roll()
	


