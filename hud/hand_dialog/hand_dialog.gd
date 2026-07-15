## hand_dialog.gd
class_name HandDialog
extends PanelContainer

var RESOURCE_QTY_LABEL_MAP: Dictionary[Model.ResourceTypes, Label] = {}
var RESOURCE_EX_LABEL_MAP: Dictionary[Model.ResourceTypes, Label] = {}

func _ready() -> void:
	EventBus.current_phase_updated.connect(self._on_current_phase_updated)
	EventBus.model_loaded.connect(self._on_model_loaded)


func _on_current_phase_updated(phase: Model.GamePhase) -> void:
	match phase:
		Model.GamePhase.NOT_STARTED: 
			self.visible = true
		Model.GamePhase.MAIN: 
			self.visible = true
		_: self.visible = false


func _on_model_loaded() -> void:	
	self._on_current_phase_updated(Game.model.get_current_phase())
