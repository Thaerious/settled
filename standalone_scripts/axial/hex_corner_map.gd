## hex_corner_map.gd
class_name HexCornerMap
extends RefCounted

var hex_to_corners: Dictionary[Vector3i, AxialSet] = {}
var corner_to_hexes: Dictionary[Vector3i, AxialSet] = {}
var _hexes: AxialSet


func _init(hexes: AxialSet):
	self._hexes = hexes

	for hex in hexes:
		var hex_key := hex.to_vec3i()
		if hex_key not in self.hex_to_corners:
			self.hex_to_corners[hex_key] = AxialSet.new()

		for c in Axial.CORNERS:
			var corner: Axial = Axial.new(hex.q + c.x, hex.r + c.y, hex.s + c.z)
			self.hex_to_corners[hex_key].add_item(corner)

	for hex in hexes:
		for corner in self.get_corners(hex):
			var corner_key := corner.to_vec3i()
			if corner_key not in self.corner_to_hexes:
				self.corner_to_hexes[corner_key] = AxialSet.new()

			self.corner_to_hexes[corner_key].add_item(hex)


func all_hexes() -> AxialSet:
	return self._hexes.clone()


func all_corners() -> AxialSet:
	return self._hexes.flat_map(Axial.corners_of)


func get_corners(hex: Axial) -> AxialSet:
	return self.hex_to_corners.get(hex.to_vec3i(), AxialSet.new())


func get_hexes(corner: Axial) -> AxialSet:
	return self.corner_to_hexes.get(corner.to_vec3i(), AxialSet.new())
