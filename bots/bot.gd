class_name Bot
extends RefCounted

# return true if an exchange is possible
static func poll_exchange(exchange: Wallet, wallet: Wallet, cost: Wallet) -> bool:
	# the number of resources needed to purchase
	var remaining = wallet.duplicate().remove(cost)	
	var short = remaining.select(func(_r, v): return v < 0)
	remaining = remaining.select(func(_r, v): return v > 0)
	var exchangeable = remaining.map(func(r, v): return v / exchange.get_resource(r))
	
	if exchangeable.sum() < (short.sum() * -1):
		# no exchange possible
		return false
	else:       
		# exchange is possible
		return true    


static func do_exchange(id:int, model: Model, cost: Wallet) -> bool:
	var rates = model.get_exchange_rate(id)
	var wallet = model.get_bank(id).remove(cost)	

	# create an array of required resources
	# subtract cost from wallet, anything less than 0 is short
	var short:Array = wallet.map(func(_r, v): 
		if v < 0: return v * -1
		return 0
	).to_array()

	# delete insufficient resources from rates
	for r in rates.keys():
		if not wallet.has(r, rates.get_resource(r)):
			rates.erase(r)

	while rates.keys().size() > 0 and short.size() > 0:
		print("Wallet %s" % wallet)
		print("Rates %s" % rates)	
		var next_short = short.pop_front()
		var next_resource = rates.min()
		EventBus.request_exchange.emit(id, next_resource, next_short)

		wallet = model.get_bank(id).remove(cost)

		if not wallet.has(next_resource, rates.get_resource(next_resource)):
			rates.erase(next_resource)

	return short.size() == 0