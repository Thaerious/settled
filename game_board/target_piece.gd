class_name TargetPiece
extends Node2D


var _current_piece: GamePiece = null


func set_piece(game_piece: GamePiece) -> void:    
    if self._current_piece == game_piece: return
    self.clear_piece()
    print("target.set ", self)
    self._current_piece = game_piece
    self.add_child(game_piece)


func clear_piece() -> void:
    if not self._current_piece: return
    print("target.clear ", self)
    self.remove_child(self._current_piece)
    self._current_piece = null