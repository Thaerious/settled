class_name SelectablePanelContainer
extends PanelContainer

signal panel_selected(panel: SelectablePanelContainer)

@export var selected: bool = false:
	get:
		return selected
	set(value):
		selected = value
		if selected:
			self.add_theme_stylebox_override("panel", self.selected_style)
		else:
			self.add_theme_stylebox_override("panel", self.normal_style)


@export var selected_style: StyleBox
@export var normal_style: StyleBox

func _gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton: return
	if not event.button_index == MOUSE_BUTTON_LEFT: return
	if not event.is_pressed(): return

	self.selected = !self.selected
	self.panel_selected.emit(self)
	
