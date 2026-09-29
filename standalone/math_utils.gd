# filename: standalone/math_utils.gd
class_name MathUtils


# return an array of all numbers from x to upper -1, excluding 'except'
static func range_except(upper: int, except: int) -> Array:
	var result := []
	for x in range(upper):
		if x != except:
			result.append(x)
	return result


static func weighted_random(rng:RandomNumberGenerator, weights: Variant) -> Variant:
	var dict: Dictionary = weights if weights is Dictionary else weights.to_dict()	
	var total := 0
	
	for key in dict.keys():
		total += dict.get(key, 0)

	var roll := rng.randi_range(0, total - 1)
	var cumulative := 0
	for key in dict:
		cumulative += dict[key]
		if roll < cumulative:
			return key

	return dict.keys().back()