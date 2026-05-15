class_name RoadCalculator
extends RefCounted


# corner key -> list of reachable corners via player roads
static var adj: Dictionary[String, Array] = {}


static func calculate_longest_road(id: int, model: Model) -> int:
	var edges := Game.model.get_roads(id)
	if edges.is_empty(): return 0

	# get all unique corners touched by this player's roads
	var corners := edges.corner_map(AxialEdge.corners_of)

	# build adjacency for this player's road network
	_build_adjacency(id)

	# try every corner as a starting point and keep the best
	var best := 0
	for corner in corners:
		best = maxi(best, _dfs(id, corner))

	return best


static func _dfs(id: int, start: Axial) -> int:
	# each queue entry is [visited_edge_keys, current_corner]
	# visited is a Dictionary used as a set of edge keys already used in this path
	var queue = [[{}, start]]
	var best := 0

	while not queue.is_empty():
		var next = queue.pop_front()
		var traversed: Dictionary = next[0] # edges already traversed
		var current: Axial = next[1]        # the next corner to visit

		# path length = number of edges traversed so far
		best = maxi(best, traversed.size())

		# for each neighboring corner we can reach from the current corner
		for neighbor: Axial in adj[current.key()]:
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


static func _build_adjacency(id: int) -> void:
	adj.clear()
	var edges := Game.model.get_roads(id)
	var corners := edges.corner_map(AxialEdge.corners_of)

	# initialise empty lists for each corner
	for corner in corners:
		adj[corner.key()] = []

	# for each road, add each endpoint as reachable from the other
	for edge in edges:
		adj[edge.ax1.key()].append(edge.ax2)
		adj[edge.ax2.key()].append(edge.ax1)


static func _edge_key(a: Axial, b: Axial) -> String:
	return AxialEdge.new(a, b).key()


static func _is_blocked(corner: Axial, player_id: int) -> bool:
	# a corner is blocked if any opponent has a settlement or city there
	for i in range(Game.player_count):
		if i == player_id:
			continue
		if Game.model.get_all_buildings(i).has_axial(corner):
			return true
	return false
