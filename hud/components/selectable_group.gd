# Targetting the immediate child nodes, which must have the signals "on_selected", and "on_unselected" 
# as well as the property "selected".  When one child is selected the others are unselected.

class_name SelectableGroup
extends Node

signal on_selection_changed(target: Node)
var current_selection_index: int = -1
var _selectable_children = []

var current_selection: Node = null:
	get:
		return current_selection
	set(v):
		self.hnd_selected(v)


# Called when the node enters the scene tree for the first time.
func _ready():
	var all: Array[Node] = find_children("*", "DialogControl", true, false)

	for child in all:
		child.on_selected.connect(func(): self.current_selection = child)
		_selectable_children.append(child)
		if child.selected: self.current_selection = child


func hnd_selected(target: Node):
	if target == self.current_selection: return
	self.current_selection_index = self.get_children().find(target)

	for child in _selectable_children:	
		if child == target: continue
		child.selected = false
	
	self.on_selection_changed.emit(target)
		
