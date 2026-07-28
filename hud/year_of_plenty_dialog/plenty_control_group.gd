extends HBoxContainer

var wallet := Wallet.new()

@onready var _controls = [
	%WoodControl,
	%BrickControl,
	%WheatControl,
	%RockControl,
	%WoolControl
]


func _ready() -> void:
	EventBus.current_phase_updated.connect(self._update_phase)
	for control in self._controls: control.count_changed.connect(self._on_count_changed)


func _update_phase(_phase: Model.GamePhase) -> void:
	for control in self._controls: control.reset()	


func _on_count_changed(resource: Model.ResourceTypes, count: int) -> void:
	wallet.set_resource(resource, count)

	for control in self._controls: 
		control.check_state(wallet.size() != 2)

	if wallet.size() != 2:
		%ButtonAccept.disabled = true
	else:
		%ButtonAccept.disabled = false