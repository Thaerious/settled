class_name HexData
extends RefCounted

var axial: Axial = null
var terrain: Model.Terrain
var resource := Model.ResourceTypes.NONE
var number: int = -1
var pirate: bool = false
var ports: AxialSet = AxialSet.new()
var port_type := Model.ResourceTypes.NONE

func _to_string() -> String:
	return "HexData(axial=%s, terrain=%s, resource=%s, number=%d, pirate=%s, ports=%d, port_type=%s)" % [
		self.axial,
		Model.Terrain.find_key(self.terrain),
		Model.ResourceTypes.find_key(self.resource),
		self.number,
		self.pirate,
		self.ports.size(),
		Model.ResourceTypes.find_key(self.port_type)
	]

func serialize() -> Dictionary:
	return {
		"axial": self.axial.serialize(),
		"terrain": self.terrain,
		"resource": self.resource,
		"number": self.number,
		"pirate": self.pirate,
		"ports": self.ports.serialize(),
		"port_type": self.port_type
	}

static func deserialize(data: Dictionary) -> HexData:
	var hex := HexData.new()
	hex.axial = Axial.deserialize(data["axial"])
	hex.terrain = data["terrain"]
	hex.resource = data["resource"]
	hex.number = data["number"]
	hex.pirate = data["pirate"]
	hex.ports = AxialSet.deserialize(data["ports"])
	hex.port_type = data["port_type"]
	return hex	