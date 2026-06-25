extends PanelContainer


@export var enabled := true

func _ready() -> void:
	self.mouse_entered.connect(self._mouse_entered)
	self.mouse_exited.connect(self._mouse_exited)

func _mouse_entered() -> void:
	if not self.enabled: return

func _mouse_exited() -> void:
	if not self.enabled: return