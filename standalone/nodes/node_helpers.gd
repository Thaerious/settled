class_name NodeHelpers

static func print_tree_from(node: Node, indent: int = 0) -> void:
	print("%s%s (%s)" % ["  ".repeat(indent), node.name, node.get_class()])
	for child in node.get_children():
		print_tree_from(child, indent + 1)


static func get_first_child_of_type(node: Variant, type: Variant) -> Node:
	for child in node.get_children():
		if is_instance_of(child, type):
			return child
	return null		