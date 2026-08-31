## board.gd
class_name GameBoard
extends Node2D

@onready var structures: Node2D = %Structures
@onready var tiles: TileMapLayer = %Tiles

const CORNER_TARGET: PackedScene = preload("res://game_board/corner_target.tscn")
const EDGE_TARGET: PackedScene = preload("res://game_board/edge_target.tscn")
const HOUSE_PIECE: PackedScene = preload("res://game_board/house_piece.tscn")
const CITY_PIECE: PackedScene = preload("res://game_board/city_piece.tscn")
const ROAD_PIECE: PackedScene = preload("res://game_board/road_piece.tscn")

## player tint for game pieces
static var tint: Array = [
	Color("#ff0000"),
	Color("#00ff00"),
	Color("#0000ff"),
	Color("#ffffff")
]


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


func _ready() -> void:
	self._setup()

	EventBus.show_house_targets.connect(self.show_house_targets_hnd)
	EventBus.show_city_targets.connect(self.show_city_targets_hnd)
	EventBus.show_road_targets.connect(self.show_road_targets_hnd)

	EventBus.clear_targets.connect(self.clear_targets_hnd)
	EventBus.house_added.connect(self.set_house_hnd)
	EventBus.city_added.connect(self.set_city_hnd)
	EventBus.road_added.connect(self.set_road_hnd)

	EventBus.model_loaded.connect(self._model_loaded)

func _setup() -> void:
	var setup = GameBoardSetup.new(self)
	setup.place_tiles()


# debug function - Alt LMB
var last: Array = []
func _input(event: InputEvent) -> void:
	if not event is InputEventMouseButton: return
	if not event.pressed: return
	if not event.alt_pressed: return

	var local_pos := self.tiles.get_local_mouse_position()
	var hex := Axial.offset_to_axial(self.tiles.local_to_map(local_pos))
	var corners := hex.corners()
	var data = Game.model.get_hex_data(hex)

	print(" --- HEX %s ---" % hex)
	if data != null: print(" - %s" % [data])

	self.clear_targets_hnd()
	
	var targets = self.show_targets(corners)
	for target in targets:
		target.area_2d.input_event.connect(func(_1, e, _2): self._on_input_target(target, e))


func _on_input_target(target, event) -> void:	
	if not event is InputEventMouseButton: return
	if not MouseHelper.is_left_press(event): return
	
	print(" - %s %s" % [target.get_script().get_global_name(), target.axial])


func _model_loaded() -> void:
	# clear targets
	clear_targets_hnd()

	# clear structures
	for child in self.structures.get_children():
		child.queue_free()

	# replay from model
	for i in range(4):
		for corner in Game.model.get_houses(i):
			set_house_hnd(i, corner)
		for corner in Game.model.get_cities(i):
			set_city_hnd(i, corner)
		for edge in Game.model.get_roads(i):
			set_road_hnd(i, edge)

	# reset board
	self.tiles.clear()	
	self._setup()


func show_house_targets_hnd():
	if Game.model.get_current_phase() == Model.GamePhase.SETUP:
		self.show_targets(Game.model.playable_corners())
	else:
		self.show_targets(Game.model.playable_corners(Game.self_id))


func show_city_targets_hnd():
	self.show_targets(Game.model.get_houses(Game.self_id))


func show_road_targets_hnd():
	if Game.model.get_current_phase() == Model.GamePhase.SETUP:
		self.show_targets(Game.model.get_initial_road_targets(Game.self_id))
	else:
		self.show_targets(Game.model.playable_edges(Game.self_id))		


func get_hexes_for_vertex(hex: Vector2i) -> Vec2iSet:
	return self._vertex_hexes[hex]


func get_vertex_neighbors(vector: Vector2i):
	return self.vertex_neighbors[vector]


func clear_targets_hnd():
	for child in self.structures.get_children():
		if child is EdgeTarget: child.queue_free()
		if child is CornerTarget: child.queue_free()


func set_house_hnd(id: int, corner: Axial) -> void:
	var house_piece := HOUSE_PIECE.instantiate()
	house_piece.modulate = self.tint[id]
	house_piece.position = corner.map_to_local(self.tiles)
	house_piece.axial = corner
	%Structures.add_child(house_piece)


func set_city_hnd(id: int, corner: Axial) -> void:
	var city_piece := CITY_PIECE.instantiate()
	city_piece.modulate = self.tint[id]
	city_piece.position = corner.map_to_local(self.tiles)
	%Structures.add_child(city_piece)	
	self.remove_house_piece(corner)		


func remove_house_piece(corner: Axial):
	for child in self.structures.get_children():
		if not child is HousePiece: continue
		if not child.axial.equals(corner): continue
		child.queue_free()


func set_road_hnd(id: int, edge: AxialEdge) -> void:
	var road_piece := ROAD_PIECE.instantiate()
	road_piece.modulate = self.tint[id]
	road_piece.position = edge.map_to_local(self.tiles)
	%Structures.add_child(road_piece)
	road_piece.rotation = edge.rotation


# Show one or more axial/edgeaxial targets.
# Accepts collections and single axials.
# Returns a map of axial -> target
func show_targets(ax: Variant) -> Array[Node]:
	var targets: Array[Node] = []
	var target: Node2D

	if ax is Axial:
		target = CORNER_TARGET.instantiate()
		target.axial = ax
		targets.append(target)
		target.position = ax.map_to_local(self.tiles)
		self.structures.add_child(target)		
	elif ax is AxialEdge:
		target = EDGE_TARGET.instantiate()
		target.axial_edge = ax
		targets.append(target)
		target.position = ax.map_to_local(self.tiles)
		self.structures.add_child(target)		
	else:
		for _ax in ax: 
			targets.append_array(self.show_targets(_ax))

	return targets