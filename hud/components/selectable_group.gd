# Targetting the immediate child nodes, which must have the signals "on_selected", and "on_unselected" 
# as well as the property "selected".  When one child is selected the others are unselected.

class_name SelectableGroup
extends Node

signal on_selection_changed(target: Node)
var current_selection: Node = null
var current_selected_index: int = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in self.get_children():
		assert("selected" in child)
		assert("on_selected" in child)
		assert("on_unselected" in child)
		child.on_selected.connect(func(): self.hnd_selected(child))


func hnd_selected(target: Node):
	if target == self.current_selection: return
	self.current_selection = target
	self.current_selected_index = 0

	for child in self.get_children():		
		if child == target: continue
		child.selected = false
		self.current_selected_index += 1

	self.on_selection_changed.emit(target)
		