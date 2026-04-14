# structures.gd
extends Node2D

const SettlementScene := preload("res://game_board/house_piece.tscn")
const CityScene       := preload("res://game_board/city_piece.tscn")
const IndicatorScene  := preload("res://game_board/target_piece.tscn")

## Canonical vertex positions → placed structure node
var _structures: Dictionary = {}

## Canonical vertex positions → indicator node
var _indicators: Dictionary = {}


## Snap a world position to a rounded key to absorb floating point drift.
func _snap_key(pos: Vector2) -> Vector2i:
	return Vector2i(roundi(pos.x), roundi(pos.y))
	

## Show placement indicators at all valid empty vertices.
func show_indicators(positions: Array[Vector2]) -> void:
	self.clear_indicators()
	for pos in positions:
		var key := self._snap_key(pos)
		if self._structures.has(key):
			continue
		var ind: Node2D = IndicatorScene.instantiate()
		ind.position = pos
		self.add_child(ind)
		self._indicators[key] = ind

func clear_indicators() -> void:
	for ind in self._indicators.values():
		ind.queue_free()
	self._indicators.clear()
