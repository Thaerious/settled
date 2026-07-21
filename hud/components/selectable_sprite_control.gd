@tool
class_name SelectableSpriteControl
extends DialogSpriteControl

signal on_selected()
signal on_unselected()


@export var selected := false:
	get: 
		return selected
	set(v): 
		if selected == v: return
		selected = v
		if self.selected: self.on_selected.emit()
		else: self.on_unselected.emit()		
		if not is_node_ready(): return
		self._update_style()


func _ready() -> void:
	super._ready()	


func _post_ready() -> void:
	super._post_ready()
	self.clicked.connect(self._on_clicked)


func _on_clicked() -> void:
	if self.disabled: return
	self.selected = !self.selected	


func _update_style() -> void:
	if self.disabled: 
		self.mouse_default_cursor_shape = Control.CURSOR_ARROW
		%StyleHelper.style = "default"
	elif self._hover and self.selected:
		self.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND	
		%StyleHelper.style = "selected_hover"		
	elif self._hover:
		self.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND	
		%StyleHelper.style = "hover"
	elif self.selected:
		self.mouse_default_cursor_shape = Control.CURSOR_ARROW	
		%StyleHelper.style = "selected"		
	else:
		self.mouse_default_cursor_shape = Control.CURSOR_ARROW
		%StyleHelper.style = "default"	
