class_name BotBasic
extends RefCounted

var _game_model: Model
var _resource_counts := Wallet.new()
var id: int

var ranks: Dictionary[String, int] = {}:
	get:
		if ranks.is_empty(): 
			ranks = self.rank_all()
		return ranks

# unique resource weights
var resource_w: Dictionary[Model.ResourceTypes, int] = {
	Model.ResourceTypes.WOOD: 30,
	Model.ResourceTypes.BRICK: 30,
	Model.ResourceTypes.WHEAT: 25,
	Model.ResourceTypes.ROCK: 20,
	Model.ResourceTypes.WOOL: 25
}

# port weights
var port_w: Dictionary[Model.ResourceTypes, int] = {
	Model.ResourceTypes.NONE: 0,
	Model.ResourceTypes.WOOD: 0,
	Model.ResourceTypes.BRICK: 0,
	Model.ResourceTypes.WHEAT: 0,
	Model.ResourceTypes.ROCK: 0,
	Model.ResourceTypes.WOOL: 0,
	Model.ResourceTypes.ANY: 25
}

# weight for numbers
var pirate_w: Dictionary[int, int] = {
	2: 1,
	3: 2,
	4: 3,
	5: 7,
	6: 10,
	8: 10,
	9: 7,
	10: 3,
	11: 2,
	12: 1
}

# weight for numbers
var number_w: Dictionary[int, int] = {
	2: 0,
	3: 10,
	4: 20,
	5: 40,
	6: 80,
	8: 80,
	9: 40,
	10: 20,
	11: 10,
	12: 0
}

# weight for distance (number of roads to build)
var distance_w: Dictionary[int, int] = {
	0: 30,
	1: 20,
	2: 5,
	3: 5,
	4: 0
}

var path_builder: PathBuilder = null
var port_w_delta: int = 10 # applied for each resource
var resource_w_delta: int = 5
var number_w_delta: int = 15
var base_card: int = 30
var afford_card: int = 15
var pirate_card: int = 30

func distance_weight(distance: int) -> int:
	if distance_w.has(distance): return distance_w[distance]
	return 0


func _init(id: int, game_model: Model) -> void:
	self.id = id
	self._game_model = game_model
	self._pre_process()


# record the resource counts of occupied tiles
# adjust the weights for resource type and tile number
func _pre_process() -> void:
	self._resource_counts = Wallet.new()

	for corner in self._game_model.get_houses(self.id):
		for hex in corner.hexes():
			var hex_data := self._game_model.get_hex_data(hex)
			if hex_data.number == -1: continue
			self._resource_counts.add_resource(hex_data.resource)
			self.resource_w[hex_data.resource] -= self.resource_w_delta
			self.port_w[hex_data.resource] += self.port_w_delta

	for corner in self._game_model.get_cities(self.id):
		for hex in corner.hexes():
			var hex_data := self._game_model.get_hex_data(hex)
			if hex_data.number == -1: continue
			self._resource_counts.add_resource(hex_data.resource, 2)
			self.resource_w[hex_data.resource] -= (self.resource_w_delta * 2)
			self.port_w[hex_data.resource] += (self.port_w_delta * 2)

	# discourage repeat ports
	for corner in self._game_model.get_all_buildings(self.id):
		var port = self._game_model.get_port(corner)
		if port == Model.ResourceTypes.NONE: continue			
		self.port_w[port] = 0

	# initialize path_builder
	self.path_builder = PathBuilder.new().run(self._game_model, self.id)


func process() -> void:
	var action = self.get_action()	
	self.do_action(action)


func get_action() -> Array[Variant]:
	var action = [-INF, "no-op"]	

	if self._game_model.get_current_phase() == Model.GamePhase.SETUP:
		action = self.phase_setup()
	elif self._game_model.get_current_phase() == Model.GamePhase.PRE_ROLL:
		action = self.phase_pre_roll()		
	elif self._game_model.get_current_phase() == Model.GamePhase.MAIN:
		action = self.phase_main()
		print("Bot Desired Action %s" % [action])
		action = self.exchange_if(action)
	elif self._game_model.get_current_phase() == Model.GamePhase.MOVE_PIRATE:
		action = self.phase_move_pirate()
	elif self._game_model.get_current_phase() == Model.GamePhase.STEAL_RESOURCES:
		action = self.phase_steal_resource()
	elif self._game_model.get_current_phase() == Model.GamePhase.DISCARD:
		action = self.phase_discard()		

	return action


func do_action(best: Array[Variant]) -> void:
	print("bot_basic.do_action(%s)" % [best])

	match best[1]:
		"house": 		
			EventBus.request_house.emit(self.id, best[2])
		"city": 
			EventBus.request_city.emit(self.id, best[2])
		"road": 
			EventBus.request_road.emit(self.id, best[2])
		"card": 
			EventBus.request_purchase_action_card.emit(self.id)
		"pirate":
			EventBus.request_set_pirate.emit(self.id, best[2])
		"steal":
			EventBus.request_steal_from.emit(self.id, best[2])
		"discard":
			EventBus.request_discard.emit(self.id, best[2])
		"roll":
			EventBus.request_roll.emit()
		"end":
			EventBus.request_end_turn.emit()
		"wait":
			pass
		"no-op":
			EventBus.error.emit("Bot no-op")			


func phase_setup() -> Array[Variant]:
	match self._game_model.get_placement_phase(self.id):
		Model.PlacementPhase.HOUSE1:
			return self.initial_house()
		Model.PlacementPhase.ROAD1:
			return self.initial_road()
		Model.PlacementPhase.HOUSE2:
			return self.initial_house()
		Model.PlacementPhase.ROAD2:
			return self.initial_road()
		_:
			return [-INF, "no-op"]


func exchange_if(action: Array[Variant]) -> Array[Variant]:
	if not action[1] in Model.COSTS.keys(): return action
	var wallet = self._game_model.get_bank(self.id)
	var cost = Model.COSTS[action[1]]
	if wallet.has(cost): return action
	
	if poll_exchange(action[1]):
		self.do_exchange(action[1])
		return action
	else:
		return [-INF, "end"]


func phase_pre_roll() -> Array[Variant]:
	return [INF, "roll"]


# Assign a value to each corner and edge based on what can be
# built on it.  Roads take the value of highest corner they path to.
func rank_all() -> Dictionary[String, int]:
	var house_ranks := self.rank_houses()
	var city_ranks := self.rank_cities()
	return house_ranks.merged(city_ranks)


func phase_main() -> Array[Variant]:  # [rank, item, data, ...]
	var ranks := self.rank_all()
	var best := [-INF, "end"]

	for key in self.rank_cities():
		if ranks[key] <= best[0]: continue
		best = [ranks[key], "city", Axial.from_key(key)]

	for key in self.rank_houses():
		if ranks[key] <= best[0]: continue
		var path = self.path_builder.paths[key]
		if path.size() == 0:
			best = [ranks[key], "house", Axial.from_key(key)]
		else:
			best = [ranks[key], "road", AxialEdge.from_key(path[0])]


	var rank_card = self._rank_card()
	if rank_card[0] > best[0]: best = rank_card	

	return best


func poll_exchange(action: String) -> bool:
	var exchange = self._game_model.get_exchange_rate(self.id) # this is a copy
	var wallet = self._game_model.get_bank(self.id)
	var cost = Model.COSTS[action]

	# the number of resources needed to purchase
	var remaining = wallet.duplicate().remove(cost)	
	var short = remaining.select(func(_r, v): return v < 0)
	remaining = remaining.select(func(_r, v): return v > 0)
	var exchangeable = remaining.map(func(r, v): return v / exchange.get_resource(r))

	# print("Wallet %s" % wallet)
	# print("Cost %s" % cost)
	# print("Remaining %s" % remaining)
	# print("Short %s %s" % [short, short.sum()])
	# print("Exchangable %s %s" % [exchangeable, exchangeable.sum()])
	
	if exchangeable.sum() < (short.sum() * -1):
		# no exchange possible
		return false
	else:       
		# exchange is possible
		return true                


func do_exchange(action: String) -> void:
	var ex_rates = self._game_model.get_exchange_rate(self.id)
	var wallet = self._game_model.get_bank(self.id)		
	var cost = Model.COSTS[action]
	var remaining = wallet.duplicate().remove(cost)	
	var short = remaining.select(func(_r, v): return v < 0)
	short = short.map(func(_r, v): return v * -1)
	var exchangeable = remaining.map(func(r, v): return v / ex_rates.get_resource(r))

	var ex_keys = exchangeable.to_array()
	var short_keys = short.to_array()

	ex_keys.sort_custom(func(a, b):
		return ex_rates.get_resource(a) < ex_rates.get_resource(b)
	)
	
	while short_keys.size() > 0:
		var next_exchange = ex_keys.pop_front()
		var next_short = short_keys.pop_front()
		EventBus.request_exchange.emit(self.id, next_exchange, next_short)


# Decide which long term action to take
# Returns [rank, action, data, ...]
func rank_houses() -> Dictionary[String, int]:
	var ranks:Dictionary[String, int] = {}

	var reachable := self.path_builder.visited_corners
	var playable := Game.model.playable_corners()
	var corners := reachable.intersect(playable)

	for corner in corners:
		var rank = self.rank_corner(corner)
		ranks[corner.key()] = rank

	return ranks


# Decide which long term action to take
# Returns [rank, action, data, ...]
func rank_cities() -> Dictionary[String, int]:
	var ranks:Dictionary[String, int] = {}

	# Evaluate each valid corner that can accept a city
	for corner in self._game_model.get_houses(self.id):
		ranks[corner.key()] = self.rank_corner(corner)

	return ranks


func _rank_card() -> Array[Variant]:
	var wallet = self._game_model.get_bank(self.id)
	var action = self._game_model.get_playable_action_cards(self.id)
	var cost = Model.COSTS["card"]

	var rank = self.base_card
	if wallet.has(cost): rank = rank + self.afford_card

	if self._pirate_is_on_self() and not action.has_card(Model.ActionCardTypes.SOLDIER):
		rank = rank + self.pirate_card

	return [rank, "card"]


func initial_road() -> Array[Variant]:
	var edges = self._game_model.get_initial_road_targets(self.id)
	var edge = edges.to_array().pick_random()
	return [INF, "road", edge]


func initial_house() -> Array[Variant]:	
	var best = [-INF, "no-op"]

	# check each empty corner and rank them
	for corner:Axial in self._game_model.playable_corners():
		var rank = self.rank_corner(corner)
		if rank > best[0]:
			best = [rank, "house", corner]

	return best


func rank_corner(corner: Axial) -> int:
	var port = self._game_model.get_port(corner)
	var rank = 0

	for hex:Axial in corner.hexes():
		var hex_data := self._game_model.get_hex_data(hex)
		if hex_data.number == -1: continue

		# adjust rank for the number
		var hex_rank = self.number_w[hex_data.number]

		# adjust rank for the resource
		hex_rank = hex_rank + self.resource_w[hex_data.resource]

		# if the resource matches the port add the weight
		if hex_data.resource == port:
			hex_rank += self.port_w[port]

		rank += hex_rank		

	return rank


func phase_move_pirate() -> Array[Variant]:
	# count the number of buildings on a hex (house 1, city 2)
	# and multiply it by the number_w
	# skip hexes the player occupies

	var best = [-INF, "no-op"]	

	var houses = self._game_model.get_houses()
	var cities = self._game_model.get_cities()
	var owned_houses = self._game_model.get_houses(self.id)

	for hex_data: HexData in self._game_model.all_hex_data():
		if hex_data.number == -1: continue
		if hex_data.axial.equals(self._game_model.get_pirate()): continue
		var rank = 0

		for corner in hex_data.axial.corners():				
			if owned_houses.has(corner):
				break
			elif houses.has(corner):
				rank = rank + self.pirate_w[hex_data.number]
			elif cities.has(corner):
				rank = rank + (self.pirate_w[hex_data.number] * 2)

			if rank > best[0]:
				best = [rank, "pirate", hex_data.axial]

	return best


func phase_steal_resource() -> Array[Variant]:
	var best = [-INF, "no-op"]	

	for corner in self._game_model.get_pirate().corners():
		var owner = self._game_model.get_owner(corner)
		if owner == self.id: continue
		if owner == -1: continue

		var rank = self._game_model.get_bank(owner).sum()
		if rank > best[0]:
			best = [rank, "steal", owner]

	return best


func _pirate_is_on_self() -> bool:
	var pirate = self._game_model.get_pirate()
	var hex_data = self._game_model.get_hex_data(pirate)

	var first = hex_data.axial.corners().first(func(ax):
		if self._game_model.get_owner(ax) == self.id: return true
		return false			
	)

	return first != null


func phase_discard() -> Array[Variant]:
	var target = self._game_model.get_discard_target(self.id)	
	if target <= 0: return [INF, "wait"]
	# var action = self.best_building_action()
	var discard = Wallet.new()
	var wallet = self._game_model.get_bank(self.id)

	# todo account for desired target - ie don't discard house resources when going to build a house
	while target > 0:
		target = target - 1
		var resource = wallet.to_array().pick_random()
		wallet.remove(resource)
		discard.add_resource(resource)
	
	return [INF, "discard", discard]

	
