extends PanelContainer

@export var dice_textures: Array[Texture2D] = []


func _ready() -> void:
	EventBus.current_phase_updated.connect(self._hnd_current_phase_updated)
	EventBus.model_loaded.connect(self._on_model_loaded)
	EventBus.dice_set.connect(self._on_dice_set)
	%ButtonAccept.button_up.connect(self._on_button_up)
	print(self.dice_textures)

func _on_dice_set(d1: int, d2: int) -> void:
	%Die1.texture = self.dice_textures[d1 - 1]
	%Die2.texture = self.dice_textures[d2 - 1]


func _on_button_up() -> void:
	if Game.model.get_current_phase() == Model.GamePhase.MAIN:
		EventBus.request_end_turn.emit()
	else:
		EventBus.request_roll.emit()


func _hnd_current_phase_updated(phase: Model.GamePhase) -> void:
	if phase == Model.GamePhase.PRE_ROLL:
		%ButtonAccept.text = "Roll"
		%ButtonAccept.disabled = false
	elif phase == Model.GamePhase.MAIN:
		%ButtonAccept.text = "End Turn"
		%ButtonAccept.disabled = false
	else:
		%ButtonAccept.text = "End Turn"
		%ButtonAccept.disabled = true


func _on_model_loaded() -> void:
	self._hnd_current_phase_updated(Game.model.get_current_phase())	
