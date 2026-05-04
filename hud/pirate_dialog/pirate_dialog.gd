class_name PirateDialog
extends PanelContainer


var buttons: Array[Button]


# Called when the node enters the scene tree for the first time.
func _ready():
	EventBus.update_player_phase.connect(self._update_player_phase)
	for i in range(4):
		buttons[i] = get_node("%Button%s" % i)

func _label_buttons() -> void:
	for id in range(Game.player_count):
		var count = Game.model.count_resources(id)
		var player_name = Game.model.player_names[id]
		buttons[id].text = "Steal from %s with %s resourses" % [player_name, count]
		buttons[id].visible = false


func _update_player_phase(current_player: int, phase: Model.GamePhase) -> void:
	self.visible = false	

	if phase != Model.GamePhase.STEAL_RESOURCES: return
	if current_player != Game.model.get_current_player(): return

	self._label_buttons()

	var robber := Game.model.get_robber()
	var corners := robber.corners()
	var buildings := corners.intersect(Game.model.get_all_buildings())

	for ax:Axial in buildings:
		var corner_owner = Game.model.get_owner(ax)
		if corner_owner == -1: continue
		if corner_owner == Game.self_id: continue
		buttons[corner_owner].visible = true

	self.visible = true



