## axial.gd
class_name Axial
extends RefCounted

var q: int = 0
var r: int = 0
var s: int = 0

# The axial-offset of hex to hex neighbors
const NEIGHBORS: Array[Vector3i] = [
	Vector3i(1, 0, -1),
	Vector3i(1, -1, 0),
	Vector3i(0, -1, 1),
	Vector3i(-1, 0, 1),
	Vector3i(-1, 1, 0),
	Vector3i(0, 1, -1),
]

# The axial offset of hex to corners
const CORNERS: Array[Vector3i] = [
	Vector3i(1, 0, 1),
	Vector3i(1, 0, 0),
	Vector3i(1, 1, 0),
	Vector3i(0, 1, 0),
	Vector3i(0, 1, 1),
	Vector3i(0, 0, 1),
]


## Creates an Axial from a Vector3i.
static func from_vec3i(v: Vector3i) -> Axial:
	return Axial.new(v.x, v.y, v.z)


## Returns the string key for a given Axial.
static func to_key(ax: Axial) -> String:
	return ax.key()


## Creates an Axial from a dot-separated string key.
## see: to_key() & key()
static func from_key(key: String) -> Axial:
	var array = key.split(".")
	return Axial.new(int(array[0]), int(array[1]), int(array[2]))


## Returns an Axial at the origin (0, 0, 0).
static func zero() -> Axial:
	return Axial.new()


## create a new acial with specific q, r, s values.
## Defaults to origin (0, 0, 0)
func _init(q: int = 0, r: int = 0, s: int = 0):
	self.q = q
	self.r = r
	self.s = s


## Returns a dot-separated string key representing this coordinate.
func key() -> String:
	return "%s.%s.%s" % [self.q, self.r, self.s]


## Returns a copy of this Axial.
func duplicate() -> Axial:
	return Axial.new(self.q, self.r, self.s)


## Converts this Axial to a Vector3i.
## see: from_vec3i
func to_vec3i() -> Vector3i:
	return Vector3i(self.q, self.r, self.s)


## Returns a string repesentation of this Axial.
func _to_string() -> String:
	return "(%d, %d, %d)" % [self.q, self.r, self.s]


## Returns a new Axial offset by another Axial.
func transform(other: Axial) -> Axial:
	return Axial.new(self.q + other.q, self.r + other.r, self.s + other.s)


## Returns a new Axial scaled (multiplied) by an integer factor.
func scale(x: int) -> Axial:
	return Axial.new(self.q * x, self.r * x, self.s * x)


## Returns a new Axial with all components negated.
func invert() -> Axial:
	return Axial.new(self.q * -1, self.r * -1, self.s * -1)


## Returns the neighboring coordinates.
## For hexes: the 6 adjacent hexes.
## For even corners: the 3 adjacent even-axis neighbors.
## For odd corners: the 3 adjacent odd-axis neighbors.
func neighbors() -> AxialSet:
	var aset := AxialSet.new()

	if self.is_hex():
		for neighbor in Axial.NEIGHBORS:
			var ax := Axial.from_vec3i(neighbor)
			aset.add_item(self.duplicate().transform(ax))
	elif self.is_even():
		aset.add_item(self.duplicate().transform(Axial.new(-1, 0, 0)))
		aset.add_item(self.duplicate().transform(Axial.new(0, -1, 0)))
		aset.add_item(self.duplicate().transform(Axial.new(0, 0, -1)))
	else:
		aset.add_item(self.duplicate().transform(Axial.new(1, 0, 0)))
		aset.add_item(self.duplicate().transform(Axial.new(0, 1, 0)))
		aset.add_item(self.duplicate().transform(Axial.new(0, 0, 1)))

	return aset


## Static helper to get neighbors of a given Axial.
static func neighbors_of(ax: Axial) -> AxialSet:
	return ax.neighbors()


## For hexes: returns the 6 edges of this hex as an AxialEdgeSet.
## For corners: returns the 3 edges connecting to adjacent corners.
func edges() -> AxialEdgeSet:
	var aset := AxialEdgeSet.new()

	if self.is_hex():
		var corners := self.corners().to_array()
		aset.add_item(AxialEdge.new(corners[0], corners[1], deg_to_rad(30)))
		aset.add_item(AxialEdge.new(corners[1], corners[2], deg_to_rad(90)))
		aset.add_item(AxialEdge.new(corners[2], corners[3], deg_to_rad(-30)))
		aset.add_item(AxialEdge.new(corners[3], corners[4], deg_to_rad(30)))
		aset.add_item(AxialEdge.new(corners[4], corners[5], deg_to_rad(90)))
		aset.add_item(AxialEdge.new(corners[5], corners[0], deg_to_rad(-30)))
	elif self.is_even():
		aset.add_item(AxialEdge.new(self, self.transform(Axial.new(-1, 0, 0)), deg_to_rad(-30)))
		aset.add_item(AxialEdge.new(self, self.transform(Axial.new(0, -1, 0)), deg_to_rad(90)))
		aset.add_item(AxialEdge.new(self, self.transform(Axial.new(0, 0, -1)), deg_to_rad(30)))
	else:
		aset.add_item(AxialEdge.new(self, self.transform(Axial.new(1, 0, 0)), deg_to_rad(-30)))
		aset.add_item(AxialEdge.new(self, self.transform(Axial.new(0, 1, 0)), deg_to_rad(90)))
		aset.add_item(AxialEdge.new(self, self.transform(Axial.new(0, 0, 1)), deg_to_rad(30)))

	return aset


## Static helper to get edges of a given Axial.
static func edges_of(ax: Axial) -> AxialEdgeSet:
	return ax.edges()


## Returns the 6 corner coordinates of this hex.
func corners() -> AxialSet:
	if not self.is_hex(): push_error("Axial not a hex.")

	var aset := AxialSet.new()
	for neighbor in Axial.CORNERS:
		var ax := Axial.from_vec3i(neighbor)
		aset.add_item(self.duplicate().transform(ax))
	return aset


## Static helper to get corners of a given Axial.
static func corners_of(ax: Axial) -> AxialSet:
	return ax.corners()


## Returns the hexes that share this corner coordinate.
## Errors if called on a hex. Returns up to 3 adjacent hexes.
func hexes() -> AxialSet:
	if self.is_hex(): push_error("Axial not a corner.")

	var aset := AxialSet.new()
	for neighbor in Axial.CORNERS:
		var ax := Axial.from_vec3i(neighbor)
		ax = self.duplicate().transform(ax.invert())

		if ax.is_hex():
			aset.add_item(ax)

	return aset


## Static helper to get hexes sharing a given corner Axial.
static func hexes_of(ax: Axial) -> AxialSet:
	return ax.hexes()


## Converts this axial coordinate to a screen-space Vector2 using flat-top hex layout.
func to_screen(size: float) -> Vector2:
	var x: float = size * (sqrt(3.0) * self.q + sqrt(3.0) / 2.0 * self.r)
	var y: float = size * (3.0 / 2.0 * self.r)
	return Vector2(x, y)


## Returns true if this coordinate represents a hex center (q + r + s == 0).
func is_hex():
	return (self.q + self.r + self.s) == 0


## Returns true if this is an even corner (sum of components is even, non-zero).
func is_even():
	return (self.q + self.r + self.s) % 2 == 0


## Returns true if this is an odd corner (sum of components is odd).
func is_odd():
	return (self.q + self.r + self.s) % 2 != 0


## Converts axial coordinates to offset grid coordinates (even-r layout).
static func axial_to_offset(ax: Axial) -> Vector2i:
	@warning_ignore("integer_division")
	var col: int = ax.q + (ax.r - (ax.r & 1)) / 2
	var row: int = ax.r
	return Vector2i(col, row)


## Converts offset grid coordinates back to axial coordinates (even-r layout).
static func offset_to_axial(vec: Vector2i) -> Axial:
	@warning_ignore("integer_division")
	var q: int = vec.x - (vec.y - (vec.y & 1)) / 2
	var r: int = vec.y
	return Axial.new(q, r, -q - r)


## Returns true if this Axial equals another by component value.
func equals(other: Variant) -> bool:
	if not other is Axial: return false
	return self.q == other.q and self.r == other.r and self.s == other.s


## Returns the local screen position of this coordinate within a TileMapLayer.
## For hexes: converts via offset. For corners: averages the positions of the 3 sharing hexes.
func map_to_local(tile_map_layer: TileMapLayer) -> Vector2:
	if self.is_hex():
		var vector := Axial.axial_to_offset(self)
		return tile_map_layer.map_to_local(vector)
	else:
		var sum := Vector2.ZERO
		for hex in self.hexes(): sum += hex.map_to_local(tile_map_layer)
		return sum / 3


## Serializes this Axial to a Dictionary with q, r, s keys.
func serialize() -> Dictionary:
	return {
		"q": self.q,
		"r": self.r,
		"s": self.s
	}


## Deserializes a Dictionary with q, r, s keys into an Axial.
static func deserialize(data: Dictionary) -> Axial:
	return Axial.new(data["q"], data["r"], data["s"])