class_name TimeEstimator
extends RefCounted


var _game_model: Model
var id: int
var time := 0
const TIMELIMIT = 10

var _accumulator: Dictionary[Model.ResourceTypes, float] = {
	Model.ResourceTypes.WOOD: 0.0,
	Model.ResourceTypes.BRICK: 0.0,
	Model.ResourceTypes.WHEAT: 0.0,
	Model.ResourceTypes.ROCK: 0.0,
	Model.ResourceTypes.WOOL: 0.0
}

var _rate: Dictionary[Model.ResourceTypes, float] = {
	Model.ResourceTypes.WOOD: 0.0,
	Model.ResourceTypes.BRICK: 0.0,
	Model.ResourceTypes.WHEAT: 0.0,
	Model.ResourceTypes.ROCK: 0.0,
	Model.ResourceTypes.WOOL: 0.0
}

var _value: Dictionary[int, float] = {
	2: 4 * (1.0/36.0),
	3: 4 * (2.0/36.0),
	4: 4 * (3.0/36.0),
	5: 4 * (4.0/36.0),
	6: 4 * (5.0/36.0),
	8: 4 * (5.0/36.0),
	9: 4 * (4.0/36.0),
	10: 4 * (3.0/36.0),
	11: 4 * (2.0/36.0),
	12: 4 * (1.0/36.0)
}


func _init(id: int, game_model: Model) -> void:
	self.id = id
	self._game_model = game_model
	var bank := game_model.get_bank(id)

	for key in bank:
		self._accumulator[key] = bank.get_resource(key)

	for corner in game_model.get_houses(id):
		for hex in corner.hexes():			
			var hex_data = game_model.get_hex_data(hex)
			if hex_data.resource == Model.ResourceTypes.NONE: continue
			self._rate[hex_data.resource] = self._rate[hex_data.resource] + self._value[hex_data.number]

	for corner in game_model.get_cities(id):
		for hex in corner.hexes():			
			var hex_data = game_model.get_hex_data(hex)
			if hex_data.resource == Model.ResourceTypes.NONE: continue
			self._rate[hex_data.resource] = self._rate[hex_data.resource] + ( 2 * self._value[hex_data.number])


func _accumulate() -> void:
	self.time = self.time + 1
	for key in self._accumulator:
		self._accumulator[key] = snapped(self._accumulator[key] + self._rate[key], 0.1)


func estimate(cost: Wallet) -> int:
	var exr = self._game_model.get_exchange_rate(self.id)

	while self.time < TIMELIMIT:
		var wallet = Wallet.new(self._accumulator)
		if wallet.has(cost): break
		if Bot.poll_exchange(exr, wallet, cost): break
		self._accumulate()


	return self.time
