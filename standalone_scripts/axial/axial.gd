## axial.gd
class_name Axial
extends RefCounted

var q: int = 0
var r: int = 0
var s: int = 0

const NEIGHBORS: Array[Vector3i] = [
	Vector3i(1, 0, -1),
	Vector3i(1, -1, 0),
	Vector3i(0, -1, 1),
	Vector3i(-1, 0, 1),
	Vector3i(-1, 1, 0),
	Vector3i(0, 1, -1),
]

const CORNERS: Array[Vector3i] = [
	Vector3i(1, 0, 1),
	Vector3i(1, 0, 0),
	Vector3i(1, 1, 0),
	Vector3i(0, 1, 0),
	Vector3i(0, 1, 1),
	Vector3i(0, 0, 1),
]


static func from_vec3i(v: Vector3i) -> Axial:
	return Axial.new(v.x, v.y, v.z)


func _init(q: int, r: int, s: int):
	self.q = q
	self.r = r
	self.s = s


func key() -> String:
	return "%s.%s.%s" % [self.q, self.r, self.s]


func duplicate() -> Axial:
	return Axial.new(self.q, self.r, self.s)


func to_vec3i() -> Vector3i:
	return Vector3i(self.q, self.r, self.s)


func _to_string() -> String:
	return "(%d, %d, %d)" % [self.q, self.r, self.s]


static func zero() -> Axial:
	return Axial.new(0, 0, 0)


func transform(other: Axial) -> Axial:
	return Axial.new(self.q + other.q, self.r + other.r, self.s + other.s)


func scale(x: int) -> Axial:
	return Axial.new(self.q * x, self.r * x, self.s * x)


func invert() -> Axial:
	return Axial.new(self.q * -1, self.r * -1, self.s * -1)


func neighbors() -> AxialSet:
	var aset := AxialSet.new()

	if self.is_hex():
		for neighbor in Axial.NEIGHBORS:
			var ax := Axial.from_vec3i(neighbor)
			aset.add_item(self.duplicate().transform(ax))
	elif self.is_even():
		print("is even")
		aset.add_item(self.duplicate().transform(Axial.new(-1, 0, 0))) 
		aset.add_item(self.duplicate().transform(Axial.new(0, -1, 0))) 
		aset.add_item(self.duplicate().transform(Axial.new(0, 0, -1))) 
	else:
		print("is odd")
		aset.add_item(self.duplicate().transform(Axial.new(1, 0, 0))) 
		aset.add_item(self.duplicate().transform(Axial.new(0, 1, 0))) 
		aset.add_item(self.duplicate().transform(Axial.new(0, 0, 1))) 

	return aset


static func neighbors_of(ax: Axial) -> AxialSet:
	return ax.neighbors()


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


static func edges_of(ax: Axial) -> AxialEdgeSet:
	return ax.edges()


func corners() -> AxialSet:
	var aset := AxialSet.new()
	for neighbor in Axial.CORNERS:
		var ax := Axial.from_vec3i(neighbor)
		aset.add_item(self.duplicate().transform(ax))
	return aset


static func corners_of(ax: Axial) -> AxialSet:
	return ax.corners()


func hexes() -> AxialSet:
	if self.is_hex(): push_error("Axial not a corner.") 

	var aset := AxialSet.new()
	for neighbor in Axial.CORNERS:
		var ax := Axial.from_vec3i(neighbor)
		ax = self.duplicate().transform(ax.invert())
		
		if ax.is_hex(): 
			aset.add_item(ax)

	return aset


static func hexes_of(ax: Axial) -> AxialSet:
	return ax.hexes()


func to_screen(size: float) -> Vector2:
	var x: float = size * (sqrt(3.0) * self.q + sqrt(3.0) / 2.0 * self.r)
	var y: float = size * (3.0 / 2.0 * self.r)
	return Vector2(x, y)


func is_hex():
	return (self.q + self.r + self.s) == 0


# even corners require two moves to get to a hex
func is_even():
	return (self.q + self.r + self.s) % 2 == 0


# odd corners require one move to get to a hex
func is_odd():
	return (self.q + self.r + self.s) % 2 != 0


static func axial_to_offset(ax: Axial) -> Vector2i:
	@warning_ignore("integer_division")
	var col: int = ax.q + (ax.r - (ax.r & 1)) / 2
	var row: int = ax.r
	return Vector2i(col, row)


static func offset_to_axial(vec: Vector2i) -> Axial:
	@warning_ignore("integer_division")
	var q: int = vec.x - (vec.y - (vec.y & 1)) / 2
	var r: int = vec.y
	return Axial.new(q, r, -q - r)


func _equals(other: Variant) -> bool:
	if not other is Axial: return false
	return self.q == other.q and self.r == other.r and self.s == other.s


func map_to_local(tile_map_layer: TileMapLayer) -> Vector2:
	if self.is_hex():
		var vector := Axial.axial_to_offset(self)
		return tile_map_layer.map_to_local(vector)
	else:
		var sum := Vector2.ZERO
		for hex in self.hexes(): sum += hex.map_to_local(tile_map_layer)
		return sum / 3
