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
		Model.GamePhase.SETUP: 
			self.visible = false
		Model.GamePhase.DURING_DISCARD: 
			self.visible = false
		Model.GamePhase.YEAR_OF_PLENTY:
			self.visible = false
		Model.GamePhase.MONOPOLY:
			self.visible = false
		_: self.visible = true


func _on_model_loaded() -> void:	
	self._on_current_phase_updated(Game.model.get_current_phase())
