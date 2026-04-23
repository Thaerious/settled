class_name HexData
extends RefCounted

var axial: Axial = null
var terrain: String = ""
var number: int = -1
var robber: bool = false
var ports: AxialSet = AxialSet.new()
var port_type: String = "none"

func _to_string() -> String:
    return "HexData(%s, %s, %d, robber=%s, ports=%d type=%s)" % [self.axial, self.terrain, self.number, self.robber, self.ports.size(), self.port_type]