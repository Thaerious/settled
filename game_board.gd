## board.gd
extends TileMapLayer

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

## Catan board layout: ring of rows, each entry is column count.
## Pointy-top offset coords: rows 0-4, lengths 3,4,5,4,3.
## Col offsets per row to centre the board.
const ROW_SIZES := [3, 4, 5, 4, 3]
const ROW_OFFSETS := [1, 0, 0, 0, 1]

var _terrain_bag: Array[String] = []


func _ready() -> void:
	self._fill_terrain_bag()
	self._place_tiles()


func _fill_terrain_bag() -> void:
	for terrain in TERRAIN_COUNTS:
		for i in TERRAIN_COUNTS[terrain]:
			self._terrain_bag.append(terrain)
	self._terrain_bag.shuffle()


func _place_tiles() -> void:
	var bag_index := 0
	for row in ROW_SIZES.size():
		var col_count: int = ROW_SIZES[row]
		var col_offset: int = ROW_OFFSETS[row]
		for col in col_count:
			var cell := Vector2i(col + col_offset, row)
			var terrain: String = self._terrain_bag[bag_index]
			bag_index += 1
			self.set_cell(cell, TERRAIN_SOURCE_ID, Vector2i(TERRAIN[terrain], 0))