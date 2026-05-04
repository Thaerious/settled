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
	print("Pirate Dialog Ready")
	EventBus.update_player_phase.connect(self._update_player_phase)


func _label_buttons() -> void:
	for id in range(Game.player_count):
		var count = Game.model.count_resources(id)
		var player_name = Game.model.player_names[id]
		buttons[id].text = "Steal from %s with %s resourses" % [player_name, count]
		buttons[id].visible = false


func _update_player_phase(current_player: int, phase: Model.GamePhase) -> void:
	print("pirate dialog update player phase")
	self.visible = false	

	if phase != Model.GamePhase.STEAL_RESOURCES: return
	if current_player != Game.model.get_current_player(): return

	self._label_buttons()

	var robber := Game.model.get_pirate()
	var corners := robber.corners()
	print(robber, corners)
	print(Game.model.get_all_buildings())
	var buildings := corners.intersect(Game.model.get_all_buildings())

	for ax:Axial in buildings:
		var corner_owner = Game.model.get_owner(ax)
		print("axial %s owner %s" % [ax, corner_owner])
		if corner_owner == -1: continue
		if corner_owner == Game.self_id: continue
		buttons[corner_owner].visible = true

	self.visible = true
