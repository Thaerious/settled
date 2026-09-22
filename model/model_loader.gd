class_name ModelLoader
extends Object

static func save(model: Model, path: String) -> void:
	var state := {
		"current_player":        model._current_player,
		"game_phase":            Model.GamePhase.find_key(model._game_phase),
		"longest_road":          model._longest_road,
		"largest_army":          model._largest_army,
		"road_building":         model._road_building,
		"rng_state":             model.rng.state,
	}

	var data := {
		"state":                 state,
		"player_records":        serialize_dictionary(model._player_records),
		"hex_data":              serialize_dictionary(model._hex_data),			
		"bank":                  serialize_dictionary(model._bank),
		"exchange_rate":         serialize_dictionary(model._exchange_rate),
		"owned_action_cards":    serialize_dictionary(model._owned_cards),
		"playable_action_cards": serialize_dictionary(model._playable_cards),			
		"houses":                model._houses,
		"cities":                model._cities,
		"roads":                 model._roads,
		"initial_houses":        serialize_initial_houses(model._initial_houses),
		"remaining_houses":      serialize_dictionary(model._remaining_houses),
		"remaining_cities":      serialize_dictionary(model._remaining_cities),
		"remaining_roads":       serialize_dictionary(model._remaining_roads),
		"remaining_resources":   model._remaining_resources.serialize(),
		"remaining_action_cards":   model._remaining_action_cards.serialize()
	}

	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string(JSON.stringify(data, "\t"))


static func serialize_dictionary(dict: Dictionary):
	var json = {}
	for key in dict.keys():
		var value = dict[key]
		if typeof(value) == TYPE_OBJECT and value.has_method("serialize"):
			json[key] = dict[key].serialize()
		else:
			json[key] = value

	return json


static func serialize_initial_houses(dict: Dictionary):
	var json = []
	
	for p in dict:
		var next = []
		for item in dict[p]:
			next.append(item.serialize())
		json.append(next)
	
	return json


static func load(path: String) -> Model:
	var model = Model.new()
	var f := FileAccess.open(path, FileAccess.READ)
	var data: Dictionary = JSON.parse_string(f.get_as_text())

	model._road_building   = int(data["state"]["road_building"])
	model._current_player  = int(data["state"]["current_player"])
	model._game_phase      = Model.GamePhase[data["state"]["game_phase"]]
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

	var p = 0
	for k in data["initial_houses"]:
		for j in k:
			model._initial_houses[p].append(Axial.deserialize(j))
		p += 1

	model.build_derived_data()
	return model		
