class_name ShortestPathCalculator
extends RefCounted

# corner key -> list of reachable corners via player roads
var _adj: Dictionary[String, Array] = {}
var _start: Axial = null
var _end: Axial = null
var _id: int = -1
var model: Model = null


func _init(id: int, model: Model, start: Axial, end: Axial):
	self._id = id
	self.model = model
	self._start = start
	self._end = end


func calculate() -> int:
	# each queue entry is [visited_edge_keys, current_corner]
	# visited is a Dictionary used as a set of edge keys already used in this path
	var queue = [[{}, self._start]]	

	while not queue.is_empty():
		var next = queue.pop_front()
		var traversed: Dictionary = next[0] # edges already traversed
		var current: Axial = next[1]        # the next corner to visit


func _bfs() -> int:
	# each queue entry is [visited_edge_keys, current_corner]
	# visited is a Dictionary used as a set of edge keys already used in this path
	var queue = [[{}, self._start]]
	var best := 0

	var permitted_edges = self.get_permitted_edges()

	while not queue.is_empty():
		var next = queue.pop_front()
		var traversed: Dictionary = next[0] # edges already traversed
		var current: Axial = next[1]        # the next corner to visit

		# for each empty or owned edge on current,
		# add the neighboring corner if it is empty or owned
		for edge in current.edges():
			if self.model.

		# path length = number of edges traversed so far
		best = maxi(best, traversed.size())

		# for each neighboring corner we can reach from the current corner
		for neighbor: Axial in _adj[current.key()]:
			var edge_key := _edge_key(current, neighbor)

			# don't reuse an edge already in this path
			if traversed.has(edge_key):
				continue

			var new_visited := traversed.duplicate()
			new_visited[edge_key] = true

			if _is_blocked(neighbor, id):
				# opponent settlement blocks passage through this corner
				# but the road leading into it still counts
				best = maxi(best, new_visited.size())
				continue

			# otherwise, extend the search to the neighbor
			queue.push_back([new_visited, neighbor])

	return best


func get_permitted_edges():
	var playable = self.model.get_pl


# Create a dictionary with corner keys to an array of edges
# The edges are connected to the corner and 
func _build_adjacency(id: int) -> Dictionary[String, Array]:
	var adjacency: Dictionary[String, Array] = {}	
	var edges := Game.model.get_roads(id)
	var corners := edges.corner_map()

	# initialise empty lists for each corner
	for corner in corners:
		adjacency[corner.key()] = []

	# for each road, add each endpoint as reachable from the other
	for edge in edges:
		adjacency[edge.ax1.key()].append(edge.ax2)
		adjacency[edge.ax2.key()].append(edge.ax1)

	return adjacency


func _edge_key(a: Axial, b: Axial) -> String:
	return AxialEdge.new(a, b).key()


func _is_blocked(corner: Axial, player_id: int) -> bool:
	# a corner is blocked if any opponent has a settlement or city there
	for i in range(Game.player_count):
		if i == player_id:
			continue
		if Game.model.get_all_buildings(i).has_axial(corner):
			return true
	return false
