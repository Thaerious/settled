class_name ModelLoader
extends Object

static func save(model: Model, path: String) -> void:
	var data = ModelLoader.encode(model)
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string(JSON.stringify(data, "\t"))


static func encode(model: Model) -> Dictionary:
	var state := {
		"current_player":        model._current_player,
		"game_phase":            Model.GamePhase.find_key(model._game_phase),
		"setup_phase":           Model.SetupPhase.find_key(model._setup_phase),
		"longest_road":          model._longest_road,
		"largest_army":          model._largest_army,
		"road_building":         model._road_building,
		"rng_state":             model.rng.state,
	}

	var data := {
		"state":                  state,
		"player_records":         serialize(model._player_records),
		"hex_data":               serialize(model._hex_data),			
		"bank":                   serialize(model._bank),
		"exchange_rate":          serialize(model._exchange_rate),
		"owned_action_cards":     serialize(model._owned_cards),
		"playable_action_cards":  serialize(model._playable_cards),			
		"houses":                 model._houses,
		"cities":                 model._cities,
		"roads":                  model._roads,
		"initial_houses":         serialize(model._initial_houses),
		"remaining_houses":       serialize(model._remaining_houses),
		"remaining_cities":       serialize(model._remaining_cities),
		"remaining_roads":        serialize(model._remaining_roads),
		"remaining_resources":    serialize(model._remaining_resources),
		"remaining_action_cards": serialize(model._remaining_action_cards)
	}

	return data



static func serialize(object: Variant):
	if typeof(object) == TYPE_OBJECT and object.has_method("serialize"):
		return object.serialize()
	elif object is Dictionary:
		return serialize_dictionary(object)
	elif object is Array:
		return serialize_array(object)
	else:
		return object


static func serialize_dictionary(dict: Dictionary):
	var json = {}

	for key in dict.keys():
		json[key] = serialize(dict[key])				

	return json


static func serialize_array(array: Array):
	var json = []

	for value in array:
		json.append(serialize(value))

	return json


static func load(path: String) -> Model:
	var model = Model.new()
	var f := FileAccess.open(path, FileAccess.READ)
	var data: Dictionary = JSON.parse_string(f.get_as_text())

	model._road_building   = int(data["state"]["road_building"])
	model._current_player  = int(data["state"]["current_player"])
	model._game_phase      = Model.GamePhase[data["state"]["game_phase"]]
	model._setup_phase     = Model.SetupPhase[data["state"]["setup_phase"]]
	model._largest_army    = int(data["state"]["largest_army"])	
	model._longest_road    = int(data["state"]["longest_road"])
	model.rng.state        = int(data["state"]["rng_state"])
	model._remaining_resources = Wallet.deserialize(data["remaining_resources"])
	model._remaining_action_cards = ActionCardWallet.deserialize(data["remaining_action_cards"])

	for k in data["player_records"]:
		model._player_records[int(k)] = PlayerRecord.deserialize(int(k), data["player_records"][k])		

	for k in data["hex_data"]:
		model._hex_data[k] = HexData.deserialize(data["hex_data"][k], k)

	for k in data["houses"]: 
		model._houses[k] = int(data["houses"][k])
		model._houses_mirror[model._houses[k]].add(Axial.from_key(k))

	for k in data["cities"]: 
		model._cities[k] = int(data["cities"][k])
		model._cities_mirror[model._cities[k]].add(Axial.from_key(k))

	for k in data["roads"]: 
		model._roads[k] = int(data["roads"][k])
		model._roads_mirror[model._roads[k]].add(AxialEdge.from_key(k))
	
	for k in data["bank"]:
		var wallet := Wallet.deserialize(data["bank"][k])
		model._bank[int(k)] = wallet
	
	for k in data["exchange_rate"]:
		var wallet := Wallet.deserialize(data["exchange_rate"][k])
		model._exchange_rate[int(k)] = wallet
	
	for k in data["owned_action_cards"]:
		var wallet := ActionCardWallet.deserialize(data["owned_action_cards"][k])
		model._owned_cards[int(k)] = wallet
	
	for k in data["playable_action_cards"]:
		var wallet := ActionCardWallet.deserialize(data["playable_action_cards"][k])
		model._playable_cards[int(k)] = wallet

	for k in data["remaining_houses"]:
		model._remaining_houses[int(k)] = int(data["remaining_houses"][k]) as int

	for k in data["remaining_cities"]:
		model._remaining_cities[int(k)] = int(data["remaining_cities"][k]) as int

	for k in data["remaining_roads"]:
		model._remaining_roads[int(k)] = int(data["remaining_roads"][k]) as int		
	
	for pid in data["initial_houses"]:
		var houses: Array = []
		for j in data["initial_houses"][pid]:
			houses.append(Axial.deserialize(j))
		model._initial_houses[int(pid)] = houses

	model.build_derived_data()
	return model		
