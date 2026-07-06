class_name EdgeTarget
extends Node2D


var _current_piece: Node2D = null
var axial_edge: AxialEdge = null


func set_piece(game_piece: Node2D) -> void:    
    if self._current_piece == game_piece: return
    self.clear_piece()
    self._current_piece = game_piece
    self.add_child(game_piece)


func clear_piece() -> void:
    if not self._current_piece: return
    self.remove_child(self._current_piece)
    self._current_piece = null