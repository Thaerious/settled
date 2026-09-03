class_name InfoBoxLogger
extends RefCounted


func _init() -> void:

	EventBus.current_player_updated.connect(func(id: int):
		EventBus.message.emit(-1, "Now Playing %s" % name(id))
	)

	EventBus.current_phase_updated.connect(func(phase_i):
		var phase_s = Model.GamePhase.find_key(phase_i)
		EventBus.message.emit(-1, "Current phase %s" % phase_s)
	)

	EventBus.city_added.connect(func(id, _ax):
		EventBus.message.emit(-1, "%s placed a city" % name(id))
	)

	EventBus.house_added.connect(func(id, _ax):
		EventBus.message.emit(-1, "%s placed a house" % name(id))
	)	

	EventBus.road_added.connect(func(id, _ax):
		EventBus.message.emit(-1, "%s placed a road" % name(id))
	)		

	EventBus.dice_set.connect(func(d1, d2):
		EventBus.message.emit(-1, "%s rolled a %s [%s, %s]" % [name(), (d1 + d2), d1, d2])
	)	

	EventBus.pirate_set.connect(func(ax):
		var data = Game.model.get_hex_data(ax)
		var number = data.number
		var resource = Model.ResourceTypes.find_key(data.resource)
		EventBus.message.emit(-1, "%s moved the pirate to %s-%s" % [name(), number, resource])
	)	

	EventBus.request_steal_from.connect(func(id):
		EventBus.message.emit(-1, "%s stole from %s" % [name(), name(id)])
	)	

	EventBus.resources_received.connect(func(id, wallet):
		EventBus.message.emit(-1, "%s Received %s" % [name(id), wallet])
	)

func name(id: int = -1) -> String:
	if id == -1: id = Game.model.get_current_player()
	return Game.model.get_player_record(id).name