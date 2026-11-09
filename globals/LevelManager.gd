extends Node

var char_queue: Array[String] = []
var current_char_index = 0
var current_char_data = {}
var pinyin = ""

var skipped: int = 0
var skipped_chars: Array[String] = []

var mistakes: int = 0
var mistake_chars: Array[String] = []

# Reset
func reset_queue(new_queue: Array[String]):
	char_queue = new_queue
	current_char_index = 0
	current_char_data = Database.get_character_data(char_queue[current_char_index])
	get_pinyin()
	skipped = 0
	skipped_chars.clear()
	mistakes = 0
	mistake_chars.clear()
	
# Only 1 pinyin pronunciation from stored JSON is handled right now
func get_pinyin():
	var pinyin_raw = LevelManager.current_char_data.get("pinyin", "[]")
	if pinyin_raw.is_empty() or pinyin_raw == "[]":
		return
	var pinyin_array = JSON.parse_string(pinyin_raw)
	if pinyin_array and pinyin_array.size() > 0:
		pinyin = str(pinyin_array[0])

# Advance to the next character
func advance_character():
	if has_next_character():
		current_char_index += 1
		current_char_data = Database.get_character_data(char_queue[current_char_index])
		get_pinyin()
	
# Helper to check if there are more characters left
func has_next_character() -> bool:
	return current_char_index + 1 < char_queue.size()
	
# Helper to get the current target character's IDS
# Currently uses decomposition from database as it can be parsed easier
func get_current_ids() -> String:
	if current_char_index < char_queue.size():
		var ids = current_char_data["decomposition"]
		#var ids = current_char_data["ids_structure"]
		return ids
	return ""
	
func skip():
	skipped += 1
	skipped_chars.append(current_char_data["character"])
	
func mistake():
	mistakes += 1
	mistake_chars.append(current_char_data["character"])
