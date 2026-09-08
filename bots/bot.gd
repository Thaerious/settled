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