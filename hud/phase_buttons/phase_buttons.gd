class_name PhaseButtons
extends VBoxContainer

var phase_buttons: Dictionary = {}

@onready var button_player1: Button = %Button1
@onready var button_player2: Button = %Button2
@onready var button_player3: Button = %Button3
@onready var button_player4: Button = %Button4
@onready var button_save: Button = %ButtonSave
@onready var button_load: Button = %ButtonLoad
@onready var button_reset: Button = %ButtonReset

func _ready() -> void:
	for child in %PhaseButtons.get_children():
		if not child is PhaseButton: continue
		var phase_button = child as PhaseButton
		self.phase_buttons[phase_button.phase] = phase_button
		
		phase_button.pressed.connect(func():
			EventBus.update_player_phase.emit(Game.model.get_current_player(), phase_button.phase)
		)		

	self.button_player1.pressed.connect(func() -> void:
		EventBus.update_player_phase.emit(0, Game.model.get_current_phase())
	)
	self.button_player2.pressed.connect(func() -> void:
		EventBus.update_player_phase.emit(1, Game.model.get_current_phase())
	)
	self.button_player3.pressed.connect(func() -> void:
		EventBus.update_player_phase.emit(2, Game.model.get_current_phase())
	)
	self.button_player4.pressed.connect(func() -> void:
		EventBus.update_player_phase.emit(3, Game.model.get_current_phase())
	)		
	self.button_save.pressed.connect(func() -> void:
		Game.model.save("user://savegame.json")
	)	
	self.button_load.pressed.connect(func() -> void:
		Game.model.load("user://savegame.json")
		EventBus.reset_view.emit()
	)
	self.button_reset.pressed.connect(func() -> void:
		Game.reset()
	)		

	EventBus.update_player_phase.connect(self._on_phase_change)
	EventBus.reset_view.connect(self._reset_view)


func _reset_view() -> void:
	self._on_phase_change(Game.model.get_current_player(), Game.model.get_current_phase())
	

func _on_phase_change(current_player: int, phase: Model.GamePhase) -> void:
	var player_buttons := [
		self.button_player1,
		self.button_player2,
		self.button_player3,
		self.button_player4,
	]

	for button in self.phase_buttons.values():
		button.modulate = Color.WHITE

	for button in player_buttons:
		button.modulate = Color.WHITE

	self.phase_buttons[phase].modulate = Color.RED
	player_buttons[current_player].modulate = Color.RED
