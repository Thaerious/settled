extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var a: Axial = Axial.new(1, 0, 0)
	var b: Axial = Axial.new(1, 1, 0)
	var x: AxialEdge = AxialEdge.new(a, b)

	print(a)
	print(b)
	print(x)



