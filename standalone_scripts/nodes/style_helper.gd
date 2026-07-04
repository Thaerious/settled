class_name StyleHelper
extends Node

const NO_STYLE = "default"

@export var style: String = NO_STYLE:
	get: 
		return style
	set(v): 		
		style = v
		if v == "": self.clear()
		else: self._apply(style)


@export var target: Control = null:
	get:
		if target == null: 
			return self.get_parent()
		return target
	set(v):
		target = v


@export var style_map: Dictionary[String, Theme] = {}

func _apply(style_name: String) -> bool:
	if not style_map.has(style_name.to_lower()): return false
	self.target.theme = self.style_map[style_name.to_lower()]
	return true


func clear() -> void:
	print("StyleHelper clear style:")	
	if not style_map.has(NO_STYLE): self.target.theme = null
	else: self.target.theme = self.style_map[NO_STYLE]
