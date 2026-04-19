## board.gd
extends TileMapLayer

@onready var structures = %Structures

const TARGET_PIECE: PackedScene = preload("res://game_board/target_piece.tscn")
const HOUSE_PIECE: PackedScene = preload("res://game_board/house_piece.tscn")

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

## The offset to each vertex from a hex
var vertex_offsets: Vec2iSet = (
	Vec2iSet
	. new(
		[
			Vector2(0, -64),  # top
			Vector2(55, -32),  # top-right
			Vector2(55, 32),  # bottom-right
			Vector2(0, 64),  # bottom
			Vector2(-55, 32),  # bottom-left
			Vector2(-55, -32),  # top-left
		]
	)
)

# Storage structures for easy iterator
var _active_targets: Array[Node2D] = []
var _active_houses: Dictionary[int, AxialSet] = {}
var _terrain_bag: Array[String] = []
var _map: HexCornerMap = null


func _ready() -> void:
	self._fill_terrain_bag()
	self._place_tiles()

	for i in range(4):
		self._active_houses[i] = AxialSet.new()

	EventBus.show_house_targets.connect(self.show_house_targets_hnd)
	EventBus.clear_targets.connect(self.clear_targets_hnd)
	EventBus.set_house.connect(self.set_house_hnd)


# debug function
# var last = null
# func _input(event: InputEvent) -> void:
# 	if event is InputEventMouseButton and event.pressed:
# 		var local_pos := self.get_local_mouse_position()
# 		var hex := Axial.offset_to_axial(self.local_to_map(local_pos))
# 		var corners := hex.corners()

# 		print("hex %s | corners %s" % [hex, corners])

# 		self.clear_targets_hnd()

# 		for corner in corners:
# 			self.show_corner_target(corner)


func corner_to_screen(corner: Axial) -> Vector2:
	var hexes := corner.hexes()
	var sum := Vector2.ZERO

	for hex in corner.hexes():		
		sum += self.map_to_local(Axial.axial_to_offset(hex))

	return sum / hexes.size()


func show_house_targets_hnd():
	if self._active_houses[GameModel.self_id].size() == 0:
		self._map.all_corners().for_each(self.show_corner_target)
	else:
		var houses := self._active_houses[GameModel.self_id]
		var adjacent = houses.flat_map(Axial.neighbors_of)
		var permitted = adjacent.flat_map(Axial.neighbors_of)		
		permitted = permitted.difference(adjacent)
		permitted = permitted.difference(houses)
		permitted = permitted.intersect(self._map.all_corners())
		permitted.for_each(self.show_corner_target)


func get_hexes_for_vertex(hex: Vector2i) -> Vec2iSet:
	return self._vertex_hexes[hex]


func get_vertex_neighbors(vector: Vector2i):
	return self.vertex_neighbors[vector]


func clear_targets_hnd():
	for target in self._active_targets:
		target.get_parent().remove_child(target)
		target.queue_free()

	self._active_targets.clear()


func set_house_hnd(id: int, corner: Axial) -> void:
	self._active_houses[id].add_item(corner)
	var house_piece := HOUSE_PIECE.instantiate()
	house_piece.position = self.corner_to_screen(corner)
	%Structures.add_child(house_piece)
	print("House placed at %s" % corner)


func show_corner_target(corner: Axial):
	var target: Node2D = TARGET_PIECE.instantiate()
	target.axial = corner
	var screen_pos = self.corner_to_screen(corner)
	target.position = screen_pos
	self.structures.add_child(target)
	target.name = "TargetPiece"
	self._active_targets.append(target)


func show_city_targets():
	pass


func show_road_targets():
	pass


func _fill_terrain_bag() -> void:
	for terrain in TERRAIN_COUNTS:
		for i in TERRAIN_COUNTS[terrain]:
			self._terrain_bag.append(terrain)
	self._terrain_bag.shuffle()


func _place_tiles() -> void:
	var bag_index := 0
	var root: Axial = Axial.zero()
	var hexes: AxialSet = root.neighbors().add_item(root)
	hexes = hexes.flat_map(Axial.neighbors_of).union(hexes)

	for hex in hexes:
		var terrain: String = self._terrain_bag[bag_index]
		bag_index += 1
		var vector := Axial.axial_to_offset(hex)
		self.set_cell(vector, TERRAIN_SOURCE_ID, Vector2i(TERRAIN[terrain], 0))

	self._map = HexCornerMap.new(hexes)
