class_name CornerTarget
extends Node2D

var _current_piece: GamePiece = null
var axial: Axial = null
@onready var area_2d := %Area2D

func set_piece(game_piece: GamePiece) -> void:    
	if self._current_piece == game_piece: return
	self.clear_piece()
	self._current_piece = game_piece
	self.add_child(game_piece)


func clear_piece() -> void:
	if not self._current_piece: return
	self.remove_child(self._current_piece)
	self._current_piece = null