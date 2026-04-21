class_name GameBoardHelpers

const NUMBER_PIECE: PackedScene = preload("res://game_board/number_piece.tscn")

static func place_numbers(game_board: GameBoard) -> void:
	var number_bag:Array[int] = [2, 3, 3, 4, 4, 5, 5, 6, 6, 8, 8, 9, 9, 10, 10, 11, 11, 12]

	number_bag.shuffle()
	for hex in game_board.map.all_hexes():
		var offset := Axial.axial_to_offset(hex)

		var tile_data: TileData = game_board.get_cell_tile_data(offset)
		var terrain_type = tile_data.get_custom_data("terrain_type")

		if (terrain_type == "desert"): continue

		var piece: NumberPiece = NUMBER_PIECE.instantiate()
		piece.number = number_bag.pop_front()		
		piece.position = game_board.map_to_local(offset)
		game_board.structures.add_child(piece)
