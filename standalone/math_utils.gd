class_name MathUtils


static func range_except(upper: int, except: int) -> Array:
	var result := []
	for x in range(upper):
		if x != except:
			result.append(x)
	return result
