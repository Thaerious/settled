class_name PathBuilder
extends RefCounted

var distances: Dictionary[String, int] = {}
var paths: Dictionary[String, Array] = {}
var visited_corners := AxialSet.new()       # a collection of all visited_corners that were visited
var _white_list: AxialSet
var _model: Model = null
var _id: int = -1


func _next_corners(current_corner: Axial) -> AxialSet:
	var next_corners := AxialSet.new()

	# check every edge connected to the current corner
	for edge in current_corner.edges():

		# skip edges owned by another player (can't build road through them)
		var edge_owner = self._model.get_owner(edge)				
		if edge_owner != -1 and edge_owner != _id: continue
		
		# check both visited_corners of this edge
		for next_corner in edge.corners():
			# skip visited_corners not in the valid/reachable set
			if not self._white_list.has(next_corner): continue

			# skip visited_corners we've already visited
			if self.visited_corners.has(next_corner): continue
			
			# skip visited_corners with an opposing player's building
			var corner_owner = self._model.get_owner(next_corner)
			if corner_owner != -1 and corner_owner != _id: continue

			# record path as the previous path plus this edge
			self.paths[next_corner.key()] = self.paths[current_corner.key()] + [edge]
			next_corners.add(next_corner)

	return next_corners


# map each corner with a distance = the number of roads req'd to reach it
# do not traverse edges with opposing roads
# do not traverse visited_corners with opposing buildings
func run(model: Model, id: int) -> PathBuilder:	
	self._model = model
	self._id = id
	self._white_list = model.valid_corners()

	var queue = self._build_initial_queue()

	# Take the next available corner
	# For each child on that corner:
	# - record the distance (parent +1) this counts as visited
	# - push all adjacent, non-visited, visited_corners onto the stack
	while not queue.is_empty():
		var current = queue.pop_front()		
		for next in self._next_corners(current):
			self.distances[next.key()] = self.distances[current.key()] + 1
			self.visited_corners.add(next)
			queue.push_back(next)
	
	return self


func _build_initial_queue() -> Array[Axial]:
	var queue :Array[Axial] = []	
	
	# start with all road visited_corners that don't have on opposing building (dist = 0)
	var roads = self._model.get_roads(self._id)

	# build initial queue
	for road in roads: 
		# each road has two visited_corners, seed both as distance-0 starting points
		for corner in road.corners():
			if not self._white_list.has(corner): continue
			var owner = self._model.get_owner(corner)

			# skip visited_corners with an opposing player's building
			if owner != -1 and owner != self._id: continue
			self.distances[corner.key()] = 0
			self.paths[corner.key()] = []
			self.visited_corners.add(corner)
			queue.push_back(corner)	
	
	return queue