class_name NodeHelpers

static func print_tree_from(node: Node, indent: int = 0) -> void:
	print("%s%s (%s)" % ["  ".repeat(indent), node.name, node.get_class()])
	for child in node.get_children():
		print_tree_from(child, indent + 1)