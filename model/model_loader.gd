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
		"owned_action_cards":    serialize_dictionary(model._owned_action_cards),
		"playable_action_cards": serialize_dictionary(model._playable_action_cards),			
		"discarded":             model._discard_targets,
		"houses":                model._houses,
		"cities":                model._cities,
		"roads":                 model._roads,
		"ports":                 model._ports
	}
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string(JSON.stringify(data, "\t"))


static func serialize_dictionary(dict: Dictionary):
	var json = {}
	for key in dict.keys():
		json[key] = dict[key].serialize()
	return json


static func load(model: Model, path: String) -> void:
	var f := FileAccess.open(path, FileAccess.READ)
	var data: Dictionary = JSON.parse_string(f.get_as_text())

	model._current_player = int(data["current_player"])
	model._game_phase     = int(data["game_phase"]) as Model.GamePhase
	model._largest_army   = int(data["largest_army"])	
	model._longest_road   = int(data["longest_road"])
	model._pirate         = Axial.from_key(data["pirate"])	

	model._discard_targets = {}
	for key in data["discarded"]:
		model._discard_targets[int(key)] = data["discarded"][key] as bool

	model._player_records.clear()
	for k in data["player_records"]:
		model._player_records[int(k)] = PlayerRecord.deserialize(int(k), data["player_records"][k])

	model._hex_data.clear()
	for k in data["hex_data"]:
		model._hex_data[k] = HexData.deserialize(data["hex_data"][k])

	model._houses.clear()
	model._houses_mirror.clear()
	for k in data["houses"]: 
		model._houses[k] = int(data["houses"][k])
		model._houses_mirror[model._houses[k]].add_item(Axial.from_key(k))

	model._cities.clear()
	model._cities_mirror.clear()
	for k in data["cities"]: 
		model._cities[k] = int(data["cities"][k])
		model._cities_mirror[model._cities[k]].add_item(Axial.from_key(k))

	model._roads.clear()
	model._roads_mirror.clear()
	for k in data["roads"]: 
		model._roads[k] = int(data["roads"][k])
		model._roads_mirror[model._roads[k]].add_item(AxialEdge.from_key(k))


	for id in model._roads_mirror: model._roads_mirror[id].clear()
	for k in data["roads_mirror"]:
		var id := int(k)
		for ed in data["roads_mirror"][k]:
			var edge := AxialEdge.from_key(ed["key"])
			edge.rotation = float(ed["rot"])
			model._roads_mirror[id].append(edge)

	for k in data["bank"]:
		var w: Wallet = model._bank[int(k)]
		for r in data["bank"][k]:
			w.set_resource(int(r) as Model.ResourceTypes, int(data["bank"][k][r]))

	for k in data["exchange_rate"]:
		var w: Wallet = model._exchange_rate[int(k)]
		for r in data["exchange_rate"][k]:
			w.set_resource(int(r) as Model.ResourceTypes, int(data["exchange_rate"][k][r]))

	for k in data["owned_action_cards"]:
		var w: ActionCardWallet = model._owned_action_cards[int(k)]
		for c in data["owned_action_cards"][k]:
			w.set_card(int(c) as Model.ActionCardTypes, int(data["owned_action_cards"][k][c]))

	for k in data["playable_action_cards"]:
		var w: ActionCardWallet = model._playable_action_cards[int(k)]
		for c in data["playable_action_cards"][k]:
			w.set_card(int(c) as Model.ActionCardTypes, int(data["playable_action_cards"][k][c]))


	model._ports.clear()
	for k in data["ports"]:
		model._ports[k] = int(data["ports"][k]) as Model.ResourceTypes
