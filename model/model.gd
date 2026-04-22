class_name Model
extends Object


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

const RESOURCE_NAMES := [
	"brick",
	"wood",
	"rock",
	"wheat",
	"wool"
]

const ACTION_CARDS := [
	"knight",
	"build_road",
	"plenty",
	"monopoly",
	"victory_points"
]

enum GAME_PHASE {
	NOT_STARTED,
    SETUP_FORWARD,
    SETUP_REVERSE,
    MAIN,
    GAME_OVER,	
}

var _largest_army_player: int = -1
var _longest_road_player: int = -1
var _current_player: int = 1
var _game_phase: GAME_PHASE = GAME_PHASE.NOT_STARTED
var _robber: Axial
var _hexes: AxialSet = AxialSet.new()
var _corners: AxialSet = AxialSet.new()
var _terrain: Dictionary[String, String] = {}  # axial (hex) -> terrain
var _numbers: Dictionary[String, int] = {}     # axial (hex) -> number
var _houses: Dictionary[String, int] = {}      # axial (corner) -> player id
var _cities: Dictionary[String, int] = {}      # axial (corner) -> player id
var _roads: Dictionary[String, int] = {}       # axial edge -> player id
var _bank: Dictionary[int, Dictionary] = {}    # player id -> resource -> quantity
var _cards: Dictionary[int, Dictionary] = {}   # player id -> card -> quantity
var _victory_points: Dictionary[int, int] = {} # player id -> points
var _army : Dictionary[int, int] = {}          # player id -> soldier cards played
var _supply: Dictionary[String, int] = {}      # resource -> quantity in bank
var _ports: Dictionary[String, String] = {}    # axial edge -> resource ("any" for 3:1)

func all_hexes() -> AxialSet: return self._hexes.clone()
func all_corners() -> AxialSet:	return self._corners.clone()


func _init() -> void:
	self.build_axials()
	self.place_tiles()
	self.place_numbers()

	EventBus.set_house.connect(func (id, ax): self._houses[ax.key()] = id)
	EventBus.set_city.connect(func (id, ax): self._cities[ax.key()] = id)
	EventBus.set_road.connect(func (id, ax): self._roads[ax.key()] = id)

	for r in RESOURCE_NAMES:
		self._supply[r] = 19

	for i in range(1, 5):
		self._bank[i] = {}
		self._cards[i] = {}
		self._army[i] = 0
		self._victory_points[i] = 0

		for r in RESOURCE_NAMES:
			self._bank[i][r] = 0

		for c in ACTION_CARDS:
			self._cards[i][c] = 0			


func build_axials() -> void:
	var neighbors := Axial.zero().neighbors() # first ring
	var distant_neighbors := neighbors.flat_map(Axial.neighbors_of) # second ring

	self._hexes.add_item(Axial.zero())
	self._hexes.add_items(neighbors)
	self._hexes.add_items(distant_neighbors)
	self._corners = self._hexes.flat_map(Axial.corners_of)


func place_tiles() -> void:
	var terrain_bag := self._fill_terrain_bag()

	for hex in self._hexes:
		var terrain: String = terrain_bag.pop_front()
		self._terrain[hex.key()] = terrain


func _fill_terrain_bag() -> Array[String]:
	var terrain_bag: Array[String] = []           

	for terrain in TERRAIN_COUNTS:
		for i in TERRAIN_COUNTS[terrain]:
			terrain_bag.append(terrain)
	terrain_bag.shuffle()

	return terrain_bag


func place_numbers() -> void:
	var number_bag:Array[int] = [2, 3, 3, 4, 4, 5, 5, 6, 6, 8, 8, 9, 9, 10, 10, 11, 11, 12]

	number_bag.shuffle()
	for hex in self._hexes:
		if (self._terrain[hex.key()] == "desert"):
			self._robber = hex
		else:
			self._numbers[hex.key()] = number_bag.pop_front()