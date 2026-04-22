## self._board_setup.gd
class_name GameBoardSetup

const TERRAIN_SOURCE_ID := 0

const TERRAIN := {
	"hills": 0,
	"forest": 1,
	"mountains": 2,
	"fields": 3,
	"pasture": 4,
	"desert": 5,
	"ocean": 6,
}

const TERRAIN_COUNTS := {
	"hills": 3,
	"forest": 4,
	"mountains": 3,
	"fields": 4,
	"pasture": 4,
	"desert": 1,
}


const NUMBER_PIECE: PackedScene = preload("res://game_board/number_piece.tscn")          
var _board: GameBoard


func _init(board: GameBoard) -> void:
	self._board = board


func place_tiles() -> GameBoardSetup:
	var root: Axial = Axial.zero()
	var hexes: AxialSet = root.neighbors().add_item(root)
	hexes = hexes.flat_map(Axial.neighbors_of).union(hexes)
	var terrain_bag := self._fill_terrain_bag()

	for hex in hexes:
		var terrain: String = terrain_bag.pop_front()
		var vector := Axial.axial_to_offset(hex)
		self._board.set_cell(vector, TERRAIN_SOURCE_ID, Vector2i(TERRAIN[terrain], 0))

	self._board.map = HexCornerMap.new(hexes)
	return self


func _fill_terrain_bag() -> Array[String]:
	var terrain_bag: Array[String] = []           

	for terrain in TERRAIN_COUNTS:
		for i in TERRAIN_COUNTS[terrain]:
			terrain_bag.append(terrain)
	terrain_bag.shuffle()

	return terrain_bag


func place_numbers() -> GameBoardSetup:
	var number_bag:Array[int] = [2, 3, 3, 4, 4, 5, 5, 6, 6, 8, 8, 9, 9, 10, 10, 11, 11, 12]

	number_bag.shuffle()
	for hex in self._board.map.all_hexes():
		var offset := Axial.axial_to_offset(hex)

		var tile_data: TileData = self._board.get_cell_tile_data(offset)
		var terrain_type = tile_data.get_custom_data("terrain_type")

		if (terrain_type == "desert"): continue

		var piece: NumberPiece = NUMBER_PIECE.instantiate()
		piece.number = number_bag.pop_front()		
		piece.position = self._board.map_to_local(offset)
		self._board.structures.add_child(piece)

	return self