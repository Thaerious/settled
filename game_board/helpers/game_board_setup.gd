## self._board_setup.gd
class_name GameBoardSetup

const TERRAIN_SOURCE_ID := 0

const TERRAIN_TILE := {
	Model.Terrain.HILL: Vector2i(0, 0),
	Model.Terrain.FOREST: Vector2i(1, 0),
	Model.Terrain.MOUNTAIN: Vector2i(2, 0),
	Model.Terrain.FIELD: Vector2i(3, 0),
	Model.Terrain.PASTURE: Vector2i(4, 0),
	Model.Terrain.DESERT: Vector2i(5, 0),
	Model.Terrain.WATER: Vector2i(6, 0),
}

const NUMBER_PIECE: PackedScene = preload("res://game_board/number_piece.tscn")          
const ANCHOR_PIECE: PackedScene = preload("res://game_board/anchor_piece.tscn")     
const PORT_PIECE: PackedScene = preload("res://game_board/port_piece.tscn")       

const resource_icons := {
	"brick": preload("res://assets/resources/brick.png"),
	"rock": preload("res://assets/resources/rock.png"),
	"wheat": preload("res://assets/resources/wheat.png"),
	"wood": preload("res://assets/resources/wood.png"),
	"wool": preload("res://assets/resources/wool.png"),
	"any": preload("res://assets/unknown.png"),
}

const BRICK: Texture2D = preload("res://assets/resources/brick.png")
const ROCK: Texture2D = preload("res://assets/resources/rock.png")
const WHEAT: Texture2D = preload("res://assets/resources/wheat.png")
const WOOD: Texture2D = preload("res://assets/resources/wood.png")
const WOOL: Texture2D = preload("res://assets/resources/wool.png")

var _board: GameBoard


func _init(board: GameBoard) -> void:
	self._board = board


func place_tiles() -> GameBoardSetup:
	for ax: Axial in Game.model.all_hexes():
		var hex_data = Game.model.get_hex_data(ax)
		var terrain: Model.Terrain = hex_data.terrain
		var vector := Axial.axial_to_offset(ax)
		self._board.set_cell(vector, TERRAIN_SOURCE_ID, TERRAIN_TILE[terrain], 0)
		
		if hex_data.port_type != "none":
			self._place_ports(hex_data)

	return self


func _place_ports(data: HexData):
	var hex_loc = data.axial.map_to_local(self._board)
	var port_piece := PORT_PIECE.instantiate()
	port_piece.position = hex_loc
	self._board.structures.add_child(port_piece)
	port_piece.sprite.set_texture_exact(resource_icons[data.port_type])
	port_piece.sprite.modulate = Color.BLACK

	for cax in data.ports:
		var corner_loc = cax.map_to_local(self._board)
		var anchor_piece := ANCHOR_PIECE.instantiate()
		anchor_piece.position = hex_loc.lerp(corner_loc, 0.75)
		self._board.structures.add_child(anchor_piece)


func place_numbers() -> GameBoardSetup:
	for ax: Axial in Game.model.all_hexes():
		var data = Game.model.get_hex_data(ax)
		if data.number == -1: continue
		if data.terrain == Model.Terrain.DESERT: continue

		var piece: NumberPiece = NUMBER_PIECE.instantiate()
		var offset := Axial.axial_to_offset(ax)
		piece.number = data.number	
		piece.position = self._board.map_to_local(offset)
		self._board.structures.add_child(piece)
	return self
