extends Node
class_name RadicalBuilder

func build_radical(rad) -> Radical:
	var radical = Radical.new()
	radical.number = rad.number
	radical.character = rad.character
	radical.radical_name = rad.name
	radical.pinyin = rad.pinyin
	radical.variants = []
	add_variant(radical, rad, 1)
	add_variant(radical, rad, 2)
	add_variant(radical, rad, 3)
	#radical.shape = rad.shape
	radical.svg_strokes = JSON.parse_string(rad.svg_strokes)
	radical.svg_medians = JSON.parse_string(rad.svg_medians)
	return radical
	
func add_variant(radical: Radical, rad, num: int):
	var variant = rad.get("variant_%d" % num)
	var pos = rad.get("variant_%d_pos" % num)
	radical.variants.append({
		"var": variant,
		"pos": pos
	})
