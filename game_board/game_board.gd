## board.gd
extends TileMapLayer

@onready var structures = %Structures

const TargetPiece: PackedScene = preload("res://game_board/target_piece.tscn")

const TERRAIN_SOURCE_ID := 0

const TERRAIN := {
	"hills":     0,
	"forest":    1,
	"mountains": 2,
	"fields":    3,
	"pasture":   4,
	"desert":    5,
	"ocean":     6,
}

const TERRAIN_COUNTS := {
	"hills":     3,
	"forest":    4,
	"mountains": 3,
	"fields":    4,
	"pasture":   4,
	"desert":    1,
}

const VERTEX_OFFSETS := [
	Vector2(0, -64),       # top
	Vector2(55, -32),      # top-right
	Vector2(55, 32),       # bottom-right
	Vector2(0, 64),        # bottom
	Vector2(-55, 32),      # bottom-left
	Vector2(-55, -32),     # top-left
]

## Catan board layout: ring of rows, each entry is column count.
## Pointy-top offset coords: rows 0-4, lengths 3,4,5,4,3.
## Col offsets per row to centre the board.
const ROW_SIZES := [3, 4, 5, 4, 3]
const ROW_OFFSETS := [1, 0, 0, 0, 1]


# Storage structures for easy iterator
var active_targets : Array[Node2D] = []
var _terrain_bag: Array[String] = []

func _ready() -> void:
	self._fill_terrain_bag()
	self._place_tiles()

	EventBus.show_house_targets.connect(self.show_house_targets)
	EventBus.clear_targets.connect(self.clear_targets)


func clear_targets():
	print("clear targets")
	for target in self.active_targets:
		self.structures.remove_child(target)


func show_house_targets():
	var vertices = self.all_vertices()
	for vertex in vertices:
		var target: Node2D = TargetPiece.instantiate()
		target.position = vertex
		self.active_targets.append(target)
		self.structures.add_child(target)


func show_city_targets():
	pass

func show_road_targets():
	pass


## Returns the 6 world positions for the vertices of a given cell.
func get_vertices(cell: Vector2i) -> Array[Vector2]:
	var center := self.map_to_local(cell)
	var result: Array[Vector2] = []
	for offset in VERTEX_OFFSETS:
		result.append(center + offset)
	return result


func all_vertices() -> Vec2iSet:
	var result = Vec2iSet.new()
	for cell in self.all_cells():
		for pos in self.get_vertices(cell):
			result.add_item(Vector2i(pos))		
	return result


func _fill_terrain_bag() -> void:
	for terrain in TERRAIN_COUNTS:
		for i in TERRAIN_COUNTS[terrain]:
			self._terrain_bag.append(terrain)
	self._terrain_bag.shuffle()


func all_cells() -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for row in ROW_SIZES.size():
		var col_count: int = ROW_SIZES[row]
		var col_offset: int = ROW_OFFSETS[row]
		for col in col_count:
			result.append(Vector2i(col + col_offset, row))
	return result


func _place_tiles() -> void:
	var bag_index := 0
	for cell in self.all_cells():
		var terrain: String = self._terrain_bag[bag_index]
		bag_index += 1
		self.set_cell(cell, TERRAIN_SOURCE_ID, Vector2i(TERRAIN[terrain], 0))
