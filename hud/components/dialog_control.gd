# %UniqueName lookup fails when this scene is used as a regular instance
# with editable children exposed via [editable path=...], that reassigns
# ownership of nested nodes to the outer scene root, breaking % lookups
# scoped to the base scene.
#
# Implement scenes as a "New Inherited Scene" of the base component,
# not a plain instance with editable children.
#
# Steps:
# 1. FileSystem dock → right-click base_scene.tscn → New Inherited Scene
#    (or Scene → New Inherited Scene... → pick base_scene.tscn)
# 2. Add custom child nodes under the correct parent in the inherited tree
# 3. Attach this script, or inherit it, to the inherited scene's root node

@tool
class_name DialogControl
extends Container

enum Behaviour {SELECTABLE, CLICKABLE, NONE}

signal on_clicked()
signal on_selected()
signal on_unselected()

@export var disabled := false:
	get: 
		return disabled
	set(v): 
		if disabled == v: return
		disabled = v		
		if not is_node_ready(): return
		if v: self._disable()
		else: self._enable()


@export var selected := false:
	get: 
		return selected
	set(v): 
		if selected == v: return
		selected = v
		if self.selected: self.on_selected.emit()
		else:             self.on_unselected.emit()		
		if not is_node_ready(): return
		self._update_style()

@export var hoverable: bool = true
@export var behaviour:= Behaviour.NONE

var _hover := false
var _pressed: bool = false

@onready var _style_helper := %StyleHelper


func _ready() -> void:
	call_deferred("_post_ready")


func _post_ready() -> void:
	self.mouse_entered.connect(self._on_mouse_entered)
	self.mouse_exited.connect(self._on_mouse_exited)
	self.gui_input.connect(self._on_gui_input)	
	self._update_style()


func _is_click_event(event: InputEvent):
	if MouseHelper.is_left_press(event):
		self._pressed = true
	elif MouseHelper.is_left_release(event):
		self._pressed = false
		if self.has_method("_on_clicked"): self.call("_on_clicked")
		self.on_clicked.emit()

	self._update_style()		


func _is_select_event(event: InputEvent):
	if MouseHelper.is_left_press(event):		
		self.selected = !self.selected
		self._update_style()


func _on_gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton: return
	if self.disabled: return

	if self.behaviour == Behaviour.CLICKABLE:
		self._is_click_event(event)
	elif self.behaviour == Behaviour.SELECTABLE:
		self._is_select_event(event)


func _on_mouse_entered() -> void:	
	if not self.hoverable: return
	self._hover = true
	self._update_style()


func _on_mouse_exited() -> void:
	if not self.hoverable: return	
	self._hover = false
	self._update_style()


func _update_style() -> void:
	var highlight_bg = self.selected or self._pressed

	if self.disabled: 
		self.mouse_default_cursor_shape = Control.CURSOR_ARROW
		%StyleHelper.style = "disabled"
	elif self._hover and highlight_bg:
		self.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND	
		%StyleHelper.style = "selected_hover"		
	elif self._hover:
		self.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND	
		%StyleHelper.style = "hover"
	elif highlight_bg:
		self.mouse_default_cursor_shape = Control.CURSOR_ARROW	
		%StyleHelper.style = "selected"		
	else:
		self.mouse_default_cursor_shape = Control.CURSOR_ARROW
		%StyleHelper.style = "default"						


func _enable() -> void: 
	self._update_style()


func _disable() -> void:	
	self._update_style()


func _select() -> void: 
	self._style_helper.style = "selected"


func _deselect() -> void:	
	self._style_helper.style = "default"
