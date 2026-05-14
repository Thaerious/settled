class_name RoadCalculator
extends RefCounted


static func calculate_longest_road(id: int, model: Model) -> int:
	var roads: AxialEdgeSet = Game.model.get_roads(id)
	if roads.is_empty(): return 0

	var best := 0
	for edge: AxialEdge in roads:
		best = maxi(best, _dfs(id, edge))

	return best


static func _dfs(id: int, start: AxialEdge) -> int:
	var next = [[AxialEdgeSet.new(), start]]
	var best = 0

	while not next.is_empty():
		var pair = next.pop_front()
		var visited = pair[0].duplicate()
		var current = pair[1]						
		print(visited, current)
		visited.add_item(current)
		best = maxi(best, visited.size())

		for neighbor in current.neighbors().difference(visited).intersect(Game.model.get_roads(id)):
			next.append([visited, neighbor])
	
	return best