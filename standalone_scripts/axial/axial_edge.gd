class_name AxialEdge
extends RefCounted

var ax1: Axial = null
var ax2: Axial = null
var rotation: float = 0.0

var q: float = 0.0
var r: float = 0.0
var s: float = 0.0

func _init(a: Axial, b:Axial):
	self.rotation = rotation

	self.q = float(a.q + b.q) / 2.0
	self.r = float(a.r + b.r) / 2.0
	self.s = float(a.s + b.s) / 2.0	

	self.ax1 = a.duplicate()
	self.ax2 = b.duplicate()

	if round(q) != q:
		self.rotation = deg_to_rad(-30)
	elif round(r) != r:
		self.rotation = deg_to_rad(90)
	elif round(s) != s:
		self.rotation = deg_to_rad(30)

func key() -> String:
	return "%.1f,%.1f,%.1f" % [self.q, self.r, self.s]


static func from_key(key: String) -> AxialEdge:
	var p := key.split(",")
	var q:float = float(p[0])
	var r:float = float(p[1])
	var s:float = float(p[2])

	var a: Axial
	var b: Axial

	if round(q) != q:
		a = Axial.new(int(q + 0.5), int(r), int(s))
		b = Axial.new(int(q - 0.5), int(r), int(s))
	elif round(r) != r:
		a = Axial.new(int(q), int(r + 0.5), int(s))
		b = Axial.new(int(q), int(r - 0.5), int(s))
	elif round(s) != s:
		a = Axial.new(int(q), int(r), int(s + 0.5))
		b = Axial.new(int(q), int(r), int(s - 0.5))	

	return AxialEdge.new(a, b)


func _to_string() -> String:
	return "(%s)" % [self.key()]


func duplicate() -> AxialEdge:
	return AxialEdge.new(self.ax1, self.ax2)


static func corners_of(ax: AxialEdge) -> AxialSet:
	return ax.corners()


func corners() -> AxialSet:
	return AxialSet.new([
		self.ax1.duplicate(),
		self.ax2.duplicate()
	])


func _equals(other: Variant) -> bool:
	if not other is AxialEdge: return false
	return self.ax1 == other.ax1 and self.ax2 == other.ax2	


func map_to_local(tile_map_layer: TileMapLayer) -> Vector2:
	var corners := self.corners()
	var sum := Vector2.ZERO

	for corner in corners:		
		sum += corner.map_to_local(tile_map_layer)

	return sum / corners.size()


func serialize() -> Dictionary:
	return {
		"q": self.q,
		"r": self.r,
		"s": self.s
	}


func neighbors() -> AxialEdgeSet:
	var corners = self.corners()
	var edges =  corners.edge_map(Axial.edges_of)	
	edges.remove_item(self)
	return edges


static func neighbors_of(edge: AxialEdge) -> AxialEdgeSet:
	return edge.neighbors()
