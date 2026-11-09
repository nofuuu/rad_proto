extends Node
## Manages database connections and queries

## SQLite database instance holding all dictionary and radical data
var db : SQLite

func _ready() -> void:
	db = SQLite.new()
	db.path = "res://data/dictionary_combined.db"
	db.read_only = true
	if not db.open_db():
		print("Failed to open DB")

## Retrieves the complete dictionary dataset for a specific character.
## Returns an empty dictionary [code]{}[/code] if no match is found.
func get_character_data(character):
	var query = "SELECT * FROM merged WHERE character = ?"
	db.query_with_bindings(query, [character])
	if db.query_result.size() > 0 :
		return db.query_result[0]
	else:
		return {}

## Retrieves all rows and entries from the radicals table.
func get_radicals() -> Array[Dictionary]:
	var query = "SELECT * FROM radicals"
	db.query(query)
	return db.query_result

## Finds a specific radical row by checking the base character or up to three defined variants.
## Returns null if the radical cannot be resolved.
func get_radical(radical):
	var query = """
	SELECT * FROM radicals
	WHERE character = ?
		OR variant_1 = ?
		OR variant_2 = ?
		OR variant_3 = ?
	"""
	db.query_with_bindings(query, [radical, radical, radical, radical])
	if db.query_result.size() > 0 :
		var res = db.query_result[0]
		var variant_idx = [res.get("character"), res.get("variant_1"), res.get("variant_2"), res.get("variant_3")].find(radical)
		return [res, variant_idx]
	else:
		return [null, -1]
		
func get_random_radical():
	var query = "SELECT * FROM radicals"
	db.query(query)
	var results = db.query_result
	if results.size() > 0:
		var random_index = randi() % results.size()
		return results[random_index]
	else:
		return null
	

## Searches the merged dictionary for characters matching a specific IDS spatial structure pattern.
## Returns a formatted matching string or a generic failure string.
func search_by_ids_structure(search):
	var query = "SELECT * FROM merged WHERE ids_structure = ?"
	db.query_with_bindings(query, [search])
	if db.query_result.size() > 0 :
		return "Found match: " + db.query_result[0]["character"]
	else:
		return "No match"

## Fetches IDS string structure layout of a target character
## Returns an empty string if the character does not exist in the database
func get_ids_from_character(character):
	var query = "SELECT * FROM merged WHERE character = ?"
	db.query_with_bindings(query, [character])
	if db.query_result.size() > 0 :
		return db.query_result[0]["ids_structure"]
	else:
		return ""
