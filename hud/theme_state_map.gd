class_name ThemeStateMap
extends Resource

enum ThemeState {
	DEFAULT,
	HOVER,
	SELECTED,
	DISABLED
}

@export var state_variants: Dictionary[ThemeState, StringName] = {}

func apply(control: Control, state: ThemeState, property_name := "theme_state_map") -> void:
	if state_variants.has(state):
		control.theme_type_variation = state_variants.get(state)
		print("Apply %s (%s) to to %s" % [state, state_variants.get(state), control])

	# self._propagate(control, state, property_name)

func _propagate(control: Control, state: ThemeState, property_name := "theme_state_map") -> void:
	# apply variants
	for child in control.find_children("*", "Control", true, false):
		var c := child as Control
		if not c: continue
		if not c.get(property_name): continue
		
		var child_state_map := c.get(property_name) as ThemeStateMap
		child_state_map.apply(c, state, property_name)

	# propagate further
	for child in control.find_children("*", "Control", true, false):		
		self._propagate(child, state, property_name)		