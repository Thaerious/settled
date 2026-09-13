class_name MathUtils


# return an array of all numbers from x to upper -1, excluding 'except'
static func range_except(upper: int, except: int) -> Array:
	var result := []
	for x in range(upper):
		if x != except:
			result.append(x)
	return result


static func weighted_random(rng:RandomNumberGenerator, weights: Variant) -> Variant:
	var total := 0
	for key in weights:
		total += weights[key]

	var roll := rng.randi_range(0, total - 1)
	var cumulative := 0
	for key in weights:
		cumulative += weights[key]
		if roll < cumulative:
			return key

	return weights.keys().back()