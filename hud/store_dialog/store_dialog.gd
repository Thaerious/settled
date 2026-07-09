class_name StoreDialog
extends PanelContainer


func _ready() -> void:
	EventBus.current_phase_updated.connect(func(_1): self._on_update())
	EventBus.current_player_updated.connect(func(_1): self._on_update())
	EventBus.model_loaded.connect(func(): self._on_update())
	EventBus.resources_updated.connect(func(_1, _2): self._on_update())


func _disable_all() -> void:
	%Road.disabled = true
	%House.disabled = true
	%City.disabled = true
	%Cards.disabled = true


func _on_update() -> void:
	self._disable_all()
	if Game.model.get_current_phase() != Model.GamePhase.MAIN: return
	if Game.model.get_current_player() != Game.self_id: return
	self._update_controls()


func _update_controls() -> void:
	var wallet = Game.model.get_bank(Game.self_id)

	if wallet.has_resources(Model.COSTS["road"]):
		%Road.disabled = false
	else:
		%Road.disabled = true		

	if wallet.has_resources(Model.COSTS["house"]):
		%House.disabled = false
	else:
		%House.disabled = true

	if wallet.has_resources(Model.COSTS["city"]):
		%City.disabled = false
	else:
		%City.disabled = true

	if wallet.has_resources(Model.COSTS["card"]):
		%Cards.disabled = false
	else:
		%Cards.disabled = true
