# filename: python/AxialTable.py
# LookupTable.py
from catanatron.models.map import NodeRef

# Vertex offset from tile centre
NODE_OFFSETS = {
	NodeRef.NORTH:		(1, 1, 0),
	NodeRef.NORTHEAST:	(1, 0, 0),
	NodeRef.SOUTHEAST:	(1, 0, 1),
	NodeRef.SOUTH:		(0, 0, 1),
	NodeRef.SOUTHWEST:	(0, 1, 1),
	NodeRef.NORTHWEST:	(0, 1, 0),
}

class AxialTable:
	def __init__(self, catan_map):	
		self.lookup = {}

		for cube, tile in catan_map.tiles.items():
			for ref, node_id in tile.nodes.items():
				o = NODE_OFFSETS[ref]
				self.lookup[node_id] = (cube[0] + o[0], cube[1] + o[1], cube[2] + o[2])


	def from_hex(self, cube) -> str:
		return f"{cube[0]},{cube[1]},{cube[2]}"
	

	def from_corner(self, index) -> str:
		ref = self.lookup[index]
		return f"{ref[0]},{ref[1]},{ref[2]}"	
	

	def from_edge(self, index: tuple) -> str:
		a = self.lookup[index[0]]
		b = self.lookup[index[1]]
		c = tuple((a[i] + b[i]) / 2.0 for i in range(3))
		return f"{c[0]},{c[1]},{c[2]}"