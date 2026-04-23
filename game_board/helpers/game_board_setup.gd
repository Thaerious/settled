## self._board_setup.gd
class_name GameBoardSetup

const TERRAIN_SOURCE_ID := 0

const TERRAIN_TILE := {
	"hill": Vector2i(0, 0),
	"forest": Vector2i(1, 0),
	"mountain": Vector2i(2, 0),
	"field": Vector2i(3, 0),
	"pasture": Vector2i(4, 0),
	"desert": Vector2i(5, 0),
	"water": Vector2i(6, 0),
}

const NUMBER_PIECE: PackedScene = preload("res://game_board/number_piece.tscn")          
var _board: GameBoard


func _init(board: GameBoard) -> void:
	self._board = board


func place_tiles() -> GameBoardSetup:
	for ax: Axial in Game.model.all_hexes():
		var terrain: String = Game.model.hex_data(ax).terrain
		print(terrain, TERRAIN_TILE[terrain])
		var vector := Axial.axial_to_offset(ax)
		self._board.set_cell(vector, TERRAIN_SOURCE_ID, TERRAIN_TILE[terrain], 0)
	return self


func place_numbers() -> GameBoardSetup:
	for ax: Axial in Game.model.all_hexes():
		var data = Game.model.hex_data(ax)
		if data.number == -1: continue
		if data.terrain == "desert": continue

		var piece: NumberPiece = NUMBER_PIECE.instantiate()
		var offset := Axial.axial_to_offset(ax)
		piece.number = data.number	
		piece.position = self._board.map_to_local(offset)
		self._board.structures.add_child(piece)
	return self
