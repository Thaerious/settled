class_name NodeUtility

static func promote_game_pieces(node: Node2D) -> void:
    for child: Node2D in node.get_children():        
        if child is GamePiece:      
            child.reparent(node.get_parent())      
            child.position = node.position
