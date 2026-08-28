class_name PathBuilder
extends RefCounted

var distances: Dictionary[String, int] = {}
var paths: Dictionary[String, Array] = {}
var corners := AxialSet.new()
var _white_list: AxialSet
var _model: Model = null
var _id: int = -1


func _next_corners(from: Axial) -> AxialSet:
	var next_corners := AxialSet.new()

	for edge in from.edges():
		var edge_owner = self._model.get_owner(edge)
		if edge_owner != -1 and edge_owner != _id: continue
		
		for corner in edge.corners():
			if not self._white_list.has(corner): continue
			if self.corners.has(corner): continue
			var corner_owner = self._model.get_owner(corner)
			if corner_owner != -1 and corner_owner != _id: continue
			self.distances[corner.key()] = self.distances[from.key()] + 1
			self.corners.add(corner)
			self.paths[corner.key()] = self.paths[from.key()] + [edge]
			next_corners.add(corner)

	return next_corners


# map each corner with a distance = the number of roads req'd to reach it
# do not traverse edges with opposing roads
# do not traverse corners with opposing buildings
func run(model: Model, id: int) -> PathBuilder:	
	self._model = model
	self._id = id
	self._white_list = model.valid_corners()

	var queue := []	
	
	# start with all road corners that don't have on opposing building (dist = 0)
	var roads = model.get_roads(id)

	# build initial queue
	for road in roads: 
		for corner in road.corners():
			if not self._white_list.has(corner): continue
			var owner = model.get_owner(corner)
			if owner != -1 and owner != id: continue
			self.distances[corner.key()] = 0
			self.paths[corner.key()] = []
			self.corners.add(corner)
			queue.push_back(corner)	

	while not queue.is_empty():
		var current = queue.pop_front()		
		for next in self._next_corners(current):
			self.distances[next.key()] = self.distances[current.key()] + 1
			self.corners.add(next)
			queue.push_back(next)		
	
	return self
