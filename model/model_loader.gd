class_name ModelLoader
extends Object

static func save(model: Model, path: String) -> void:

	var data := {
		"current_player":        model._current_player,
		"game_phase":            model._game_phase,
		"longest_road":          model._longest_road,
		"largest_army":          model._largest_army,
		"pirate":                model._pirate.key(),
		"player_records":        serialize_dictionary(model._player_records),
		"hex_data":              serialize_dictionary(model._hex_data),			
		"bank":                  serialize_dictionary(model._bank),
		"exchange_rate":         serialize_dictionary(model._exchange_rate),
		"owned_action_cards":    serialize_dictionary(model._owned_cards),
		"playable_action_cards": serialize_dictionary(model._playable_cards),			
		"road_building":         model._road_building,
		"houses":                model._houses,
		"cities":                model._cities,
		"roads":                 model._roads,
		"ports":                 model._ports,
		"initial_houses":        serialize_initial_houses(model._initial_houses),
		"discard_targets":       model._discard_targets
	}
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string(JSON.stringify(data, "\t"))


static func serialize_dictionary(dict: Dictionary):
	var json = {}
	for key in dict.keys():
		json[key] = dict[key].serialize()
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

	model._road_building   = int(data["road_building"])
	model._current_player  = int(data["current_player"])
	model._game_phase      = int(data["game_phase"]) as Model.GamePhase
	model._largest_army    = int(data["largest_army"])	
	model._longest_road    = int(data["longest_road"])
	model._pirate          = Axial.from_key(data["pirate"])

	var targets: Array = data["discard_targets"]
	model._discard_targets = Array(targets, TYPE_INT, "", null)

	for k in data["player_records"]:
		model._player_records[int(k)] = PlayerRecord.deserialize(int(k), data["player_records"][k])		

	for k in data["hex_data"]:
		model._hex_data[k] = HexData.deserialize(data["hex_data"][k])

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

	for k in data["ports"]:
		model._ports[k] = int(data["ports"][k]) as Model.ResourceTypes

	var p = 0
	for k in data["initial_houses"]:
		for j in k:
			model._initial_houses[p].append(Axial.deserialize(j))
		p += 1

	model.build_derived_data()
	return model		
