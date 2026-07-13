@tool
class_name YearOfPlentyDialog
extends Control

var wallet := Wallet.new()

func _ready() -> void:
	EventBus.current_phase_updated.connect(self._update_phase)

	EventBus.model_loaded.connect(func(): 
		self._update_phase(Game.model.get_current_phase())
	)

	%ButtonAccept.pressed.connect(self._accept)
	%WoodControl.count_changed.connect(self._on_count_changed)
	%BrickControl.count_changed.connect(self._on_count_changed)
	%WheatControl.count_changed.connect(self._on_count_changed)
	%RockControl.count_changed.connect(self._on_count_changed)
	%WoolControl.count_changed.connect(self._on_count_changed)


func _update_phase(phase: Model.GamePhase) -> void:
	self.visible = false	

	if phase != Model.GamePhase.YEAR_OF_PLENTY: return
	if not Game.model.get_current_player() == Game.self_id: return

	%WoodControl.reset()
	%BrickControl.reset()
	%WheatControl.reset()
	%RockControl.reset()
	%WoolControl.reset()	

	%ButtonAccept.disabled  = true

	self.visible = true	


func _on_count_changed(resource: Model.ResourceTypes, count: int) -> void:
	wallet.set_resource(resource, count)
	if wallet.size() != 2:
		%ButtonAccept.disabled = true
	else:
		%ButtonAccept.disabled = false


func _accept() -> void:
	EventBus.play_plenty_card.emit(Game.self_id, self.wallet)
