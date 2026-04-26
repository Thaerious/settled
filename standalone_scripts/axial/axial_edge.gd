class_name AxialEdge
extends RefCounted

var ax1: Axial = null
var ax2: Axial = null
var rotation: float = 0.0


func _init(a: Axial, b:Axial, rotation: float):
	self.rotation = rotation

	# normalize so A→B == B→A
	var ka := a.q + a.r * 10 + a.s * 100
	var kb := b.q + b.r * 10 + b.s * 100
	if ka > kb:
		var tmp = a
		a = b
		b = tmp

	self.ax1 = a.duplicate()
	self.ax2 = b.duplicate()


func key() -> String:
	return "%s.%s.%s.%s.%s.%s" % [self.ax1.q, self.ax1.r, self.ax1.s, self.ax2.q, self.ax2.r, self.ax2.s]


func _to_string() -> String:
	return "(%s→%s)" % [self.ax1, self.ax2]


func duplicate() -> AxialEdge:
	return AxialEdge.new(self.ax1, self.ax2, self.rotation)


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
