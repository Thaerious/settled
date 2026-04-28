extends VBoxContainer


@onready var button_not_started: Button = %ButtonNotStarted
@onready var button_setup_forward: Button = %ButtonSetupForward
@onready var button_setup_reverse: Button = %ButtonSetupReverse
@onready var button_main: Button = %ButtonMain
@onready var button_game_over: Button = %ButtonGameOver

func _ready() -> void:
	self.button_not_started.pressed.connect(func() -> void:
		EventBus.update_player_phase.emit(Game.model.get_current_player(), Model.GamePhase.NOT_STARTED)
	)
	self.button_setup_forward.pressed.connect(func() -> void:
		EventBus.update_player_phase.emit(Game.model.get_current_player(), Model.GamePhase.SETUP_FORWARD)
	)
	self.button_setup_reverse.pressed.connect(func() -> void:
		EventBus.update_player_phase.emit(Game.model.get_current_player(), Model.GamePhase.SETUP_REVERSE)
	)
	self.button_main.pressed.connect(func() -> void:
		EventBus.update_player_phase.emit(Game.model.get_current_player(), Model.GamePhase.MAIN)
	)
	self.button_game_over.pressed.connect(func() -> void:
		EventBus.update_player_phase.emit(Game.model.get_current_player(), Model.GamePhase.GAME_OVER)
	)
