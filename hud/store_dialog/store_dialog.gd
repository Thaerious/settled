class_name StoreDialog
extends DialogContainer


func _ready() -> void:
	EventBus.current_phase_updated.connect(func(_1): self._on_update())
	EventBus.current_player_updated.connect(func(_1): self._on_update())
	EventBus.model_loaded.connect(func(): self._on_update())
	EventBus.resources_updated.connect(func(_1, _2): self._on_update())


func _disable_all() -> void:
	%RoadControl.disabled = true
	%HouseControl.disabled = true
	%CityControl.disabled = true
	%CardsControl.disabled = true


func _on_update() -> void:
	self._disable_all()
	if Game.model.get_current_phase() != Model.GamePhase.MAIN: return
	if Game.model.get_current_player() != Game.self_id: return
	self._update_controls()


func _update_controls() -> void:
	var wallet = Game.model.get_bank(Game.self_id)

	if wallet.has_resources(Model.COSTS["road"]):
		%RoadControl.disabled = false
	else:
		%RoadControl.disabled = true		

	if wallet.has_resources(Model.COSTS["house"]):
		%HouseControl.disabled = false
	else:
		%HouseControl.disabled = true

	if wallet.has_resources(Model.COSTS["city"]):
		%CityControl.disabled = false
	else:
		%CityControl.disabled = true

	if wallet.has_resources(Model.COSTS["card"]):
		%CardsControl.disabled = false
	else:
		%CardsControl.disabled = true
