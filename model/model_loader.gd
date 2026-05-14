class_name ModelLoader
extends Object

static func save(model: Model, path: String) -> void:
	var records := {}
	for i in model._player_records:
		records[str(i)] = model._player_records[i].serialize()

	var hex_data := {}
	for k in model._hex_data:
		hex_data[k] = model._hex_data[k].serialize()

	var houses_mirror := {}
	for id in model._houses_mirror:
		houses_mirror[str(id)] = (model._houses_mirror[id] as Array).map(Axial.to_key)

	var cities_mirror := {}
	for id in model._cities_mirror:
		cities_mirror[str(id)] = (model._cities_mirror[id] as Array).map(Axial.to_key)

	var roads_mirror := {}
	for id in model._roads_mirror:
		roads_mirror[str(id)] = (model._roads_mirror[id] as Array).map(func(e: AxialEdge): return {
			"key": e.key(),
			"rot": e.rotation
		})

	var roads := {}
	for k in model._roads:
		roads[k] = model._roads[k]

	var bank := {}
	for id in model._bank:
		var w: Wallet = model._bank[id]
		var inner := {}
		for r in w.keys(): inner[str(r)] = w.get_resource(r)
		bank[str(id)] = inner

	var exchange_rate := {}
	for id in model._exchange_rate:
		var w: Wallet = model._exchange_rate[id]
		var inner := {}
		for r in w.keys(): inner[str(r)] = w.get_resource(r)
		exchange_rate[str(id)] = inner

	var action_cards := {}
	for id in model._action_cards:
		var w: ActionCardWallet = model._action_cards[id]
		var inner := {}
		for c in w.keys(): inner[str(c)] = w.get_card(c)
		action_cards[str(id)] = inner

	var ports := {}
	for k in model._ports:
		ports[k] = model._ports[k]

	var data := {
		"player_records":  records,
		"discarded":       model._players_discarded,
		"current_player":  model._current_player,
		"game_phase":      model._game_phase,
		"pirate":          model._pirate.key(),
		"hex_data":        hex_data,
		"houses":          model._houses,
		"cities":          model._cities,
		"roads":           roads,
		"houses_mirror":   houses_mirror,
		"cities_mirror":   cities_mirror,
		"roads_mirror":    roads_mirror,
		"bank":            bank,
		"exchange_rate":   exchange_rate,
		"action_cards":    action_cards,
		"ports":           ports,
		"longest_road":    model._longest_road,
		"largest_army":    model._largest_army
	}
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string(JSON.stringify(data, "\t"))


static func load(model: Model, path: String) -> void:
	var f := FileAccess.open(path, FileAccess.READ)
	var data: Dictionary = JSON.parse_string(f.get_as_text())

	model._players_discarded = {}
	for key in data["discarded"]:
		model._players_discarded[int(key)] = data["discarded"][key] as bool

	model._longest_road   = int(data["longest_road"])
	model._largest_army   = int(data["largest_army"])
	model._current_player = int(data["current_player"])
	model._game_phase     = int(data["game_phase"]) as Model.GamePhase
	model._pirate         = Axial.from_key(data["pirate"])

	model._player_records.clear()
	for k in data["player_records"]:
		model._player_records[int(k)] = PlayerRecord.deserialize(int(k), data["player_records"][k])

	model._hex_data.clear()
	for k in data["hex_data"]:
		model._hex_data[k] = HexData.deserialize(data["hex_data"][k])

	model._houses.clear()
	for k in data["houses"]: model._houses[k] = int(data["houses"][k])

	model._cities.clear()
	for k in data["cities"]: model._cities[k] = int(data["cities"][k])

	model._roads.clear()
	for k in data["roads"]: model._roads[k] = int(data["roads"][k])

	for id in model._houses_mirror: model._houses_mirror[id].clear()
	for k in data["houses_mirror"]:
		var id := int(k)
		for ak in data["houses_mirror"][k]:
			model._houses_mirror[id].append(Axial.from_key(ak))

	for id in model._cities_mirror: model._cities_mirror[id].clear()
	for k in data["cities_mirror"]:
		var id := int(k)
		for ak in data["cities_mirror"][k]:
			model._cities_mirror[id].append(Axial.from_key(ak))

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

	for k in data["action_cards"]:
		var w: ActionCardWallet = model._action_cards[int(k)]
		for c in data["action_cards"][k]:
			w.set_card(int(c) as Model.ActionCardTypes, int(data["action_cards"][k][c]))

	model._ports.clear()
	for k in data["ports"]:
		model._ports[k] = int(data["ports"][k]) as Model.ResourceTypes