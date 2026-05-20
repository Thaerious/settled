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
		"has_played_card":       model._has_played_card,
		"discard_target":             model._discard_target,
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


static func load(path: String) -> Model:
	var model = Model.new()
	var f := FileAccess.open(path, FileAccess.READ)
	var data: Dictionary = JSON.parse_string(f.get_as_text())

	model._current_player  = int(data["current_player"])
	model._game_phase      = int(data["game_phase"]) as Model.GamePhase
	model._largest_army    = int(data["largest_army"])	
	model._longest_road    = int(data["longest_road"])
	model._pirate          = Axial.from_key(data["pirate"])	
	model._has_played_card = bool(data["has_played_card"])

	for key in data["discard_target"]:
		model._discard_target[int(key)] = int(data["discard_target"][key])

	for k in data["player_records"]:
		model._player_records[int(k)] = PlayerRecord.deserialize(int(k), data["player_records"][k])

	for k in data["hex_data"]:
		model._hex_data[k] = HexData.deserialize(data["hex_data"][k])

	for k in data["houses"]: 
		model._houses[k] = int(data["houses"][k])
		model._houses_mirror[model._houses[k]].add_item(Axial.from_key(k))

	for k in data["cities"]: 
		model._cities[k] = int(data["cities"][k])
		model._cities_mirror[model._cities[k]].add_item(Axial.from_key(k))

	for k in data["roads"]: 
		model._roads[k] = int(data["roads"][k])
		model._roads_mirror[model._roads[k]].add_item(AxialEdge.from_key(k))

	# check
	for k in data["bank"]:
		var wallet := Wallet.deserialize(data["bank"][k])
		model._bank[int(k)] = wallet

	# check
	for k in data["exchange_rate"]:
		var wallet := Wallet.deserialize(data["exchange_rate"][k])
		model._exchange_rate[int(k)] = wallet

	# check
	for k in data["owned_action_cards"]:
		var wallet := ActionCardWallet.deserialize(data["owned_action_cards"][k])
		model._owned_cards[int(k)] = wallet

	# check
	for k in data["playable_action_cards"]:
		var wallet := ActionCardWallet.deserialize(data["playable_action_cards"][k])
		model._playable_cards[int(k)] = wallet

	for k in data["ports"]:
		model._ports[k] = int(data["ports"][k]) as Model.ResourceTypes

	return model		
