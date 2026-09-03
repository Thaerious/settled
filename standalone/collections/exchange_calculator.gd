class_name ExchangeCalculator

static func best_source_for(exchange: Wallet, wallet: Wallet, target: Model.ResourceTypes) -> Model.ResourceTypes:
	var best_source: Model.ResourceTypes = target
	var best_rate: int = -1

	for resource: Model.ResourceTypes in exchange.keys():
		if resource == target: continue

		var rate: int = exchange.get_resource(resource)

		if wallet.has_resource(resource, rate):
			if best_rate == -1 or rate < best_rate:
				best_rate = rate
				best_source = resource

	return best_source as Model.ResourceTypes