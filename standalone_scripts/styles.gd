class_name Styles
extends Control

@export var current: String = "":
	get: 
		return current
	set(v):
		current = v
		self.apply_style(self.current)

func apply_style(style_name: String) -> void:
	self._apply_style(self.get_parent(), style_name)


func _apply_style(control: Control, style_name: String) -> bool:
	var base := control.get_class()
	var variations := control.get_theme().get_type_variation_list(StringName(base))
	var root_variation = self._root_variation(control)
	var target_variation = "%s_%s" % [root_variation, style_name]

	if target_variation in variations:
		control.theme_type_variation = target_variation
		return true

	if root_variation in variations:
		control.theme_type_variation = root_variation
		return true
	
	return false


func _root_variation(control: Control) -> String:
	var variation = control.theme_type_variation
	if not variation.contains("_"): return variation
	return variation.substr(0, variation.find("_"))
