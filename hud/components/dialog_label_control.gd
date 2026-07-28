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
class_name DialogLabelControl
extends DialogControl


@export var display_text : String:
	set(value):
		display_text = value
		if not is_node_ready(): return	
		%DialogLabel.text = value


@export var horizontal_alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT:
	set(value):
		horizontal_alignment = value
		if not is_node_ready(): return
		%DialogLabel.horizontal_alignment = value


func _post_ready() -> void:
	super._post_ready()
	self.display_text = self.display_text
	self.horizontal_alignment = self.horizontal_alignment
