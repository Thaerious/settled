class_name PirateDialog
extends PanelContainer

@onready var buttons: Array[Button] = [
	%Button0,
	%Button1,
	%Button2,
	%Button3
]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.current_phase_updated.connect(self._update_phase)

	EventBus.model_loaded.connect(func(): 
		self._update_phase(Game.model.get_current_phase())
	)

	for id in range(Game.player_count):
		buttons[id].button_up.connect(func():
			EventBus.request_steal_from.emit(id)
		)	


func _label_buttons() -> void:
	for id in range(Game.player_count):
		var count = Game.model.count_resources(id)
		var player_name = Game.model.get_player_record(id).name
		buttons[id].text = "Steal from %s with %s resourses" % [player_name, count]
		buttons[id].visible = false

		self.visible = false


func _update_phase(phase: Model.GamePhase) -> void:
	self.visible = false	
	self._label_buttons()

	if phase != Model.GamePhase.STEAL_RESOURCES: return
	if not Game.model.get_current_player() == Game.self_id: return

	var robber := Game.model.get_pirate()
	var corners := robber.corners()
	var buildings := corners.intersect(Game.model.get_all_buildings())

	for ax:Axial in buildings:
		var corner_owner = Game.model.get_owner(ax)
		if corner_owner == -1: continue
		if corner_owner == Game.self_id: continue
		buttons[corner_owner].visible = true

	self.visible = true
