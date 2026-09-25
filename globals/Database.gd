extends Node
var db : SQLite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	db = SQLite.new()
	db.path = "res://data/dictionary_combined.db"
	db.read_only = true
	if not db.open_db():
		print("Failed to open DB")
		
func get_character_data(character):
	var query = "SELECT * FROM merged WHERE character = ?"
	db.query_with_bindings(query, [character])
	if db.query_result.size() > 0 :
		return db.query_result[0]
	else:
		return {}

func get_radicals() -> Array[Dictionary]:
	var query = "SELECT * FROM radicals"
	db.query(query)
	return db.query_result
	
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
		return db.query_result[0]
	else:
		return null

func search_by_ids_structure(search):
	var query = "SELECT * FROM merged WHERE ids_structure = ?"
	db.query_with_bindings(query, [search])
	if db.query_result.size() > 0 :
		return "Found match: " + db.query_result[0]["character"]
	else:
		return "No match"

func get_ids_from_character(character):
	var query = "SELECT * FROM merged WHERE character = ?"
	db.query_with_bindings(query, [character])
	if db.query_result.size() > 0 :
		return db.query_result[0]["ids_structure"]
	else:
		return ""
