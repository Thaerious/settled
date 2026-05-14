class_name PlayerRecord
extends RefCounted

var id: int
var name: String

var _victory_points: int
var victory_points: int:
	get: return _victory_points
	set(v): _victory_points = v; EventBus.player_record_updated.emit(self.id, self)

var _resources: int
var resources: int:
	get: return _resources
	set(v): _resources = v; EventBus.player_record_updated.emit(self.id, self)

var _action_cards: int
var action_cards: int:
	get: return _action_cards
	set(v): _action_cards = v; EventBus.player_record_updated.emit(self.id, self)

var _roads: int
var roads: int:
	get: return _roads
	set(v): _roads = v; EventBus.player_record_updated.emit(self.id, self)

var _soldiers: int
var soldiers: int:
	get: return _soldiers
	set(v): _soldiers = v; EventBus.player_record_updated.emit(self.id, self)


func _init(id: int, name: String) -> void:
	self.id = id
	self.name = name


func duplicate() -> PlayerRecord:
	var r := PlayerRecord.new(self.id, self.name)
	r._victory_points = self.victory_points
	r._resources      = self.resources
	r._action_cards   = self.action_cards
	r._roads          = self.roads
	r._soldiers       = self.soldiers
	return r


func serialize() -> Dictionary:
	return {
		"name":           self.name,
		"victory_points": self.victory_points,
		"resources":      self.resources,
		"action_cards":   self.action_cards,
		"roads":          self.roads,
		"soldiers":       self.soldiers,
	}


static func deserialize(id: int, data: Dictionary) -> PlayerRecord:
	var r := PlayerRecord.new(id, data["name"])
	r._victory_points = int(data["victory_points"])
	r._resources      = int(data["resources"])
	r._action_cards   = int(data["action_cards"])
	r._roads          = int(data["roads"])
	r._soldiers       = int(data["soldiers"])
	return r		


func _to_string() -> String:
	return "PlayerRecord[id:%s name:%s vp:%s res:%s cards:%s roads:%s soldiers:%s]" % [
		self.id, self.name, self._victory_points, self._resources,
		self._action_cards, self._roads, self._soldiers
	]
