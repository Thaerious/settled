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
extends PanelContainer

signal clicked()

var _hover := false
@onready var _style_helper := %StyleHelper


@export var disabled := false:
	get: 
		return disabled
	set(v): 
		if disabled == v: return
		disabled = v		
		if not is_node_ready(): return
		self._update_style()


func _ready() -> void:
	call_deferred("_post_ready")


func _post_ready() -> void:
	self.mouse_entered.connect(self._on_mouse_entered)
	self.mouse_exited.connect(self._on_mouse_exited)
	self.gui_input.connect(self._on_press)	
	self._update_style()


func _on_press(event: InputEvent) -> void:
	if self.disabled: return
	if not event is InputEventMouseButton: return
	if not MouseHelper.is_left_release(event): return
	if not get_viewport().gui_get_hovered_control(): return
	if not get_viewport().gui_get_hovered_control().owner == self: return

	self.clicked.emit()

func _on_mouse_entered() -> void:	
	self._hover = true
	self._update_style()


func _on_mouse_exited() -> void:	
	self._hover = false
	self._update_style()


func _update_style() -> void:
	print("Update Style")
	print(self._style_helper)
	print(self.disabled)
	print(self._hover)

	if self.disabled: 
		self.mouse_default_cursor_shape = Control.CURSOR_ARROW
		self._style_helper.style = "disabled"
	elif self._hover:
		self.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND	
		self._style_helper.style = "hover"
	else:
		self.mouse_default_cursor_shape = Control.CURSOR_ARROW
		self._style_helper.style = "default"					


func _enable() -> void: 
	self._style_helper.style = "default"


func _disable() -> void:	
	self._style_helper.style = "disabled"


func _select() -> void: 
	self._style_helper.style = "selected"


func _deselect() -> void:	
	self._style_helper.style = "default"
