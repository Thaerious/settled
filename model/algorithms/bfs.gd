# Given a starting point, an end point, and an adjacency table;
# determine the shortest path between the start and end point.
# Result will contain the reverse array [end, ..., start]

class_name BFS
extends RefCounted

var _start: Axial
var _end: Array[Axial]
var _adj: Dictionary[String, AxialSet]
var _visited: Dictionary[String, Axial] = {} # to -> from
var result: Array[Axial] = []


# start: Starting point
# end: Array of valid end points
# adj: Adjacenty table of connections Axial -> AxialSet
# The start point must be in one of the adjaceny keys
# The end point must be in one of the adjaceny AxialSets
func _init(start: Axial, end: Array[Axial], adj: Dictionary[String, AxialSet]):
	self._start = start
	self._end = end
	self._adj = adj

# return true if a path was found
func run() -> bool:	
	var queue := [self._start]

	while not queue.is_empty():
		var current = queue.pop_front()

		for neighbour in self._adj[current.key()]:
			if self._visited.keys().has(neighbour.key()): continue
			queue.push_back(neighbour)
			self._visited[neighbour.key()] = current

			if self._is_end(neighbour):
				self.build_path(neighbour)	
				return true		
	return false


func _is_end(point: Axial) -> bool:
	for e in self._end:
		if e.equals(point): return true
	return false


func build_path(end_point: Axial) -> void:
	var current := end_point

	while not current.equals(self._start):
		self.result.push_back(current)
		current = self._visited[current.key()]
	