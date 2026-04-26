## board.gd
class_name GameBoard
extends TileMapLayer

@onready var structures = %Structures

const CORNER_TARGET: PackedScene = preload("res://game_board/corner_target.tscn")
const EDGE_TARGET: PackedScene = preload("res://game_board/edge_target.tscn")
const HOUSE_PIECE: PackedScene = preload("res://game_board/house_piece.tscn")
const CITY_PIECE: PackedScene = preload("res://game_board/city_piece.tscn")
const ROAD_PIECE: PackedScene = preload("res://game_board/road_piece.tscn")


## The offset to each vertex from a hex
var vertex_offsets: Vec2iSet = (
	Vec2iSet.new([
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
var _corner_black_list: AxialSet = AxialSet.new()         # locations that are not permitted houses
var _active_targets: Array[Node2D] = []                   # targets currently on the board, used to clear
var _active_buildings: Dictionary[int, AxialSet] = {}     # the locations of buildings the player owns (1:n)
var _active_roads: Dictionary[int, AxialEdgeSet] = {}     # the locations (keys) of roads the player owns
var _placed_pieces: Dictionary[String, GamePiece] = {}    # which game piece belongs to which axial (1:1)


func _ready() -> void:
	var setup = GameBoardSetup.new(self)
	setup.place_tiles()
	setup.place_numbers()

	for i in range(4):
		self._active_buildings[i] = AxialSet.new()
		self._active_roads[i] = AxialEdgeSet.new()

	EventBus.show_house_targets.connect(self.show_house_targets_hnd)
	EventBus.show_city_targets.connect(self.show_city_targets_hnd)
	EventBus.show_road_targets.connect(self.show_road_targets_hnd)

	EventBus.clear_targets.connect(self.clear_targets_hnd)
	EventBus.set_house.connect(self.set_house_hnd)
	EventBus.set_city.connect(self.set_city_hnd)
	EventBus.set_road.connect(self.set_road_hnd)


# debug function
# var last = null
# func _input(event: InputEvent) -> void:
# 	if event is InputEventMouseButton and event.pressed:
# 		var local_pos := self.get_local_mouse_position()
# 		var hex := Axial.offset_to_axial(self.local_to_map(local_pos))
# 		var corners := hex.corners()

# 		print("GAME BOARD hex %s | corners %s" % [hex, corners])
# 		if Game.model.all_hexes().contains(hex):
# 			print(Game.model.get_hex_data(hex))
# 		else:
# 			print("Hex not found in model")

# 		self.clear_targets_hnd()
# 		self.show_targets(corners)

# 		var edges = hex.edges()
# 		edges.for_each(
# 			func(ax): self.set_road_hnd(0, ax)
# 		)


func show_house_targets_hnd():
	if self._active_buildings[Game.self_id].size() == 0:	
		self.show_targets(Game.model.all_corners())
	else:
		var roads := self._active_roads[Game.self_id]
		var road_corners := roads.corner_map(AxialEdge.corners_of)
		var permitted = road_corners.difference(self._corner_black_list)
		
		permitted = permitted.intersect(Game.model.all_corners())
		self.show_targets(permitted)		


func show_city_targets_hnd():
	self.show_targets(self._active_buildings[Game.self_id])


func show_road_targets_hnd():
	var houses := self._active_buildings[Game.self_id]
	var roads := self._active_roads[Game.self_id]
	var house_edges := houses.edge_map(Axial.edges_of)
	var road_corners := roads.corner_map(AxialEdge.corners_of)
	var neighbors := road_corners.edge_map(Axial.edges_of)

	house_edges = house_edges.union(neighbors)
	house_edges = house_edges.difference(roads)
	house_edges = house_edges.intersect(Game.model.all_edges())
	self.show_targets(house_edges)


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
	self._active_buildings[id].add_item(corner)
	var house_piece := HOUSE_PIECE.instantiate()
	house_piece.position = corner.map_to_local(self)
	%Structures.add_child(house_piece)
	self._placed_pieces[corner.key()] = house_piece

	self._corner_black_list.add_item(corner)
	self._corner_black_list.add_all(corner.neighbors())


func set_city_hnd(_id: int, corner: Axial) -> void:
	var city_piece := CITY_PIECE.instantiate()
	city_piece.position = corner.map_to_local(self)
	%Structures.add_child(city_piece)
	var house_piece := self._placed_pieces[corner.key()]
	house_piece.queue_free()
	self._placed_pieces[corner.key()] = city_piece


func set_road_hnd(id: int, edge: AxialEdge) -> void:
	var road_piece := ROAD_PIECE.instantiate()
	road_piece.position = edge.map_to_local(self)
	%Structures.add_child(road_piece)
	self._placed_pieces[edge.key()] = road_piece
	road_piece.rotation = edge.rotation
	self._active_roads[id].add_item(edge)


func show_targets(ax: Variant):
	var target: Node2D

	if ax is Axial:
		target = CORNER_TARGET.instantiate()
		target.axial = ax
	elif ax is AxialEdge:
		target = EDGE_TARGET.instantiate()
		target.axial_edge = ax
	else:
		for _ax in ax: self.show_targets(_ax)
		return

	target.position = ax.map_to_local(self)
	self._active_targets.append(target)
	self.structures.add_child(target)
