extends Node
class_name RadicalBuilder

const IDS_OPERATORS = {
	"⿰": 2, "⿱": 2, "⿲": 3, "⿳": 3, "⿴": 2, 
	"⿵": 2, "⿶": 2, "⿷": 2, "⿸": 2, "⿹": 2,
	"⿺": 2, "⿻": 2
}

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
	
func build_fallback_radical(strokes: Array[String], chara: String) -> Radical:
	var radical = Radical.new()
	radical.number = 0
	radical.character = chara
	radical.radical_name = "Fallback Component"
	radical.pinyin = ""
	radical.variants = []
	var stroke_array: Array = []
	stroke_array.assign(strokes)
	radical.svg_strokes = stroke_array
	radical.svg_medians = [] 
	return radical
	
# ----- Building radical layout from ids -----
func build_character_layout(ids_structure: String, raw_strokes: Variant, raw_stroke_matches: Variant, target_area: InteractionArea) -> void:
	var full_strokes: Array = JSON.parse_string(raw_strokes)
	var raw_matches: Array = JSON.parse_string(raw_stroke_matches)
	# Count how many leaf node radical slots are expected
	var total_leaves: int = 0
	for chara in ids_structure:
		if not IDS_OPERATORS.has(chara):
			total_leaves += 1
	var grouped_strokes_by_id: Dictionary = {}
	for id in range(total_leaves):
		grouped_strokes_by_id[id] = Array([], TYPE_STRING, &"", null)
	# Map out which leaf index corresponds to which database radical index
	# DB radical indexing ignores '？' placeholders.
	var known_radical_leaf_ids: Array[int] = []
	var unknown_leaf_ids: Array[int] = []
	var leaf_counter: int = 0
	for chara in ids_structure:
		if not IDS_OPERATORS.has(chara):
			if chara == "？":
				unknown_leaf_ids.append(leaf_counter)
			else:
				known_radical_leaf_ids.append(leaf_counter)
			leaf_counter += 1
	# Allocate an target leaf array for every stroke
	var stroke_mappings: Array[int] = []
	stroke_mappings.resize(raw_matches.size())
	stroke_mappings.fill(-1)
	# Translate database index to absolute layout leaf index
	for i in range(raw_matches.size()):
		var match_data = raw_matches[i]
		if typeof(match_data) == TYPE_ARRAY and not match_data.is_empty():
			var db_radical_idx: int = int(match_data[0])
			if db_radical_idx >= known_radical_leaf_ids.size() and db_radical_idx > 0:
				db_radical_idx -= 1 
			if db_radical_idx < known_radical_leaf_ids.size():
				stroke_mappings[i] = known_radical_leaf_ids[db_radical_idx]
	# Distribute null elements evenly across the '？' placeholder slots
	var null_indices: Array[int] = []
	for i in range(raw_matches.size()):
		if raw_matches[i] == null:
			null_indices.append(i)
	if not unknown_leaf_ids.is_empty() and not null_indices.is_empty():
		var nulls_per_leaf: int = ceili(float(null_indices.size()) / float(unknown_leaf_ids.size()))
		for chunk_idx in range(null_indices.size()):
			var unknown_leaf_target_idx = min(chunk_idx / nulls_per_leaf, unknown_leaf_ids.size() - 1)
			stroke_mappings[null_indices[chunk_idx]] = unknown_leaf_ids[unknown_leaf_target_idx]
	# Populate our final stroke groups
	for i in range(raw_matches.size()):
		var target_id = stroke_mappings[i]
		if target_id != -1 and i < full_strokes.size() and grouped_strokes_by_id.has(target_id):
			grouped_strokes_by_id[target_id].append(full_strokes[i])
	# Kick off the recursive parser loop
	var execution_state = {"current_radical_id": 0}
	_parse_ids_to_area(ids_structure, 0, target_area, grouped_strokes_by_id, execution_state)

func _parse_ids_to_area(chars: String, index: int, area: InteractionArea, grouped_strokes: Dictionary, state: Dictionary) -> int:
	var chara = chars[index]
	# Handle Layout Node
	if IDS_OPERATORS.has(chara):
		var count = IDS_OPERATORS[chara]
		area.create_split(chara, count)
		var container = area.split_root.get_child(0)
		var next_index = index + 1
		for i in count:
			var child = container.get_child(i)
			next_index = _parse_ids_to_area(chars, next_index, child, grouped_strokes, state)
		return next_index
	# Leaf Node (Radical Component)
	var target_id = state["current_radical_id"]
	state["current_radical_id"] += 1
	var rad = Database.get_radical(chara)
	# Core radical exists directly inside the radicals database
	if rad != null:
		var radical = build_radical(rad)
		area.set_radical({"radical": radical})
		return index + 1
	# Radical component is missing or explicitly defined as null/unknown ('？')
	var fallback_strokes: Array[String] = []
	fallback_strokes.assign(grouped_strokes.get(target_id, []))
	var fallback_radical = build_fallback_radical(fallback_strokes, chara)
	area.set_radical({"radical": fallback_radical})
	if fallback_strokes.is_empty():
		push_error("Empty stroke layout collection generated for leaf: ", chara)
	return index + 1
