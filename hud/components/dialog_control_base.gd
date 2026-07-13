# 1. Create the base scene (e.g. DialogControl.tscn)
# Build it with whatever internal structure you want — root node, any containers, 
# controls, etc.
# 2. Instance it into another scene
# In the target scene's Scene dock: 
# right-click a node → Instantiate Child Scene → pick DialogControl.tscn. 
# This adds it as a black-boxed instance — you see the root node, but not its internals.
# 3. Enable Editable Children
# Right-click that instance in the Scene dock → Editable Children. 
# Now the instance expands to show its full internal node tree, and you can select 
# any node inside it.
# 4. Add children where you want them
# With Editable Children on, select whichever internal node should be the 
# parent (e.g. an internal VBoxContainer) and add your new nodes under it directly in the Scene dock.
# 5. Save
# These additions are stored as overrides on top of the base scene in the target scene 
# file — the base DialogControl.tscn is untouched.

# Make the parent a PanelContainer so that it sizes to it's children.
# On visibility > self modulate set the alpha to 0, to make the bg transparent.
@tool
class_name DialogControlBase
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
	if self.disabled: 
		self.mouse_default_cursor_shape = Control.CURSOR_ARROW
		self._style_helper.style = "default"
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
