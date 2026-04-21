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

	self.ax1 = a.clone()
	self.ax2 = b.clone()


func key() -> String:
	return "%s.%s.%s.%s.%s.%s" % [self.ax1.q, self.ax1.r, self.ax1.s, self.ax2.q, self.ax2.r, self.ax2.s]


func _to_string() -> String:
	return "(%s→%s)" % [self.ax1, self.ax2]


static func corners_of(ax: AxialEdge) -> AxialSet:
	return ax.corners()


func corners() -> AxialSet:
	return AxialSet.new([
		self.ax1.clone(),
		self.ax2.clone()
	])