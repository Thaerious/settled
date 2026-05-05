extends VBoxContainer


@onready var button_not_started: Button = %ButtonNotStarted
@onready var button_setup_forward: Button = %ButtonSetupForward
@onready var button_setup_forward2: Button = %ButtonSetupForward2
@onready var button_setup_reverse: Button = %ButtonSetupReverse
@onready var button_setup_reverse2: Button = %ButtonSetupReverse2
@onready var button_move_pirate: Button = %ButtonMovePirate
@onready var button_discard: Button = %ButtonDiscard
@onready var button_steal_resources: Button = %ButtonSteal
@onready var button_main: Button = %ButtonMain
@onready var button_game_over: Button = %ButtonGameOver
@onready var button_player1: Button = %Button1
@onready var button_player2: Button = %Button2
@onready var button_player3: Button = %Button3
@onready var button_player4: Button = %Button4
@onready var button_save: Button = %ButtonSave
@onready var button_load: Button = %ButtonLoad
@onready var button_reset: Button = %ButtonReset

func _ready() -> void:
	self.button_not_started.pressed.connect(func() -> void:
		EventBus.update_player_phase.emit(Game.model.get_current_player(), Model.GamePhase.NOT_STARTED)
	)
	self.button_setup_forward.pressed.connect(func() -> void:
		EventBus.update_player_phase.emit(Game.model.get_current_player(), Model.GamePhase.SETUP_FORWARD_HOUSE)
	)
	self.button_setup_forward2.pressed.connect(func() -> void:
		EventBus.update_player_phase.emit(Game.model.get_current_player(), Model.GamePhase.SETUP_FORWARD_ROAD)
	)	
	self.button_setup_reverse.pressed.connect(func() -> void:
		EventBus.update_player_phase.emit(Game.model.get_current_player(), Model.GamePhase.SETUP_REVERSE_HOUSE)
	)
	self.button_setup_reverse2.pressed.connect(func() -> void:
		EventBus.update_player_phase.emit(Game.model.get_current_player(), Model.GamePhase.SETUP_REVERSE_ROAD)
	)	
	self.button_move_pirate.pressed.connect(func() -> void:
		EventBus.update_player_phase.emit(Game.model.get_current_player(), Model.GamePhase.MOVE_PIRATE)
	)
	self.button_steal_resources.pressed.connect(func() -> void:
		EventBus.update_player_phase.emit(Game.model.get_current_player(), Model.GamePhase.STEAL_RESOURCES)
	)		
	self.button_discard.pressed.connect(func() -> void:
		EventBus.update_player_phase.emit(Game.model.get_current_player(), Model.GamePhase.DISCARD)
	)		
	self.button_main.pressed.connect(func() -> void:
		EventBus.update_player_phase.emit(Game.model.get_current_player(), Model.GamePhase.MAIN)
	)
	self.button_game_over.pressed.connect(func() -> void:
		EventBus.update_player_phase.emit(Game.model.get_current_player(), Model.GamePhase.GAME_OVER)
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
	var phase_buttons := [
		self.button_not_started,
		self.button_setup_forward,
		self.button_setup_forward2,
		self.button_setup_reverse,
		self.button_setup_reverse2,
		self.button_move_pirate,
		self.button_discard,
		self.button_steal_resources,
		self.button_main,
		self.button_game_over,
	]
	var player_buttons := [
		self.button_player1,
		self.button_player2,
		self.button_player3,
		self.button_player4,
	]

	for button in phase_buttons:
		button.modulate = Color.WHITE

	for button in player_buttons:
		button.modulate = Color.WHITE

	phase_buttons[phase].modulate = Color.RED
	player_buttons[current_player].modulate = Color.RED
