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


func clone() -> Axial:
	return Axial.new(self.q, self.r, self.s)


func to_vec3i() -> Vector3i:
	return Vector3i(self.q, self.r, self.s)


func _to_string() -> String:
	return "Axial(%d, %d, %d)" % [self.q, self.r, self.s]


static func zero() -> Axial:
	return Axial.new(0, 0, 0)


func transform(other: Axial) -> Axial:
	return Axial.new(self.q + other.q, self.r + other.r, self.s + other.s)


func invert() -> Axial:
	return Axial.new(self.q * -1, self.r * -1, self.s * -1)


func neighbors() -> AxialSet:
	var aset := AxialSet.new()
	for neighbor in Axial.NEIGHBORS:
		var ax := Axial.from_vec3i(neighbor)
		aset.add_item(self.clone().transform(ax))
	return aset


static func neighbors_of(ax: Axial) -> AxialSet:
	return ax.neighbors()


func corners() -> AxialSet:
	var aset := AxialSet.new()
	for neighbor in Axial.CORNERS:
		var ax := Axial.from_vec3i(neighbor)
		aset.add_item(self.clone().transform(ax))
	return aset


static func corners_of(ax: Axial) -> AxialSet:
	return ax.corners()


func hexes() -> AxialSet:
	var aset := AxialSet.new()
	for neighbor in Axial.CORNERS:
		var ax := Axial.from_vec3i(neighbor)
		ax = self.clone().transform(ax.invert())
		if ax.q + ax.r + ax.s != 0: continue
		aset.add_item(ax)
	return aset


static func hexes_of(ax: Axial) -> AxialSet:
	return ax.hexes()
	

func to_screen(size: float) -> Vector2:
	var x: float = size * (sqrt(3.0) * self.q + sqrt(3.0) / 2.0 * self.r)
	var y: float = size * (3.0 / 2.0 * self.r)
	return Vector2(x, y)


static func axial_to_offset(ax: Axial) -> Vector2i:
	var col: int = ax.q + (ax.r - (ax.r & 1)) / 2
	var row: int = ax.r
	return Vector2i(col, row)


static func offset_to_axial(vec: Vector2i) -> Axial:
	var q: int = vec.x - (vec.y - (vec.y & 1)) / 2
	var r: int = vec.y
	return Axial.new(q, r, -q - r)
