class_name ThemeStateMap
extends Resource

enum ThemeState {
	DEFAULT,
	HOVER,
	SELECTED,
	DISABLED
}

@export var state_variants: Dictionary[ThemeState, StringName] = {}

func apply(control: Control, state: ThemeState) -> void:
	if state_variants.has(state):
		control.theme_type_variation = state_variants.get(state)
