class_name StyleContainer
extends PanelContainer

@export var style: String = "":
	get: 
		return style
	set(v): 
		style = v
		if v == "": self.clear()
		else: self._apply(style)


@export var style_map: Dictionary[String, Theme] = {}

func _apply(style_name: String) -> bool:
	if not style_map.has(style_name.to_lower()): return false
	self.theme = self.style_map[style_name.to_lower()]
	return true


func clear() -> void:
	if not style_map.has("default"): self.theme = null
	else: self.theme = self.style_map["default"]


# traverse up the node tree and _apply the style to the
# first style node found
# return true if set, else false
static func apply_style(control: Control, style_name: String) -> bool:
	var current := control
	while current != null:
		if current is StyleContainer:
			return current._apply(style_name)
		current = current.get_parent()
	return false
