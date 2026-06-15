extends Node
var db : SQLite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	db = SQLite.new()
	db.path = "res://data/dictionary_combined.db"
	db.read_only = true
	if not db.open_db():
		print("Failed to open DB")

func get_radicals() -> Array[Dictionary]:
	var query = "SELECT * FROM radicals"
	db.query(query)
	return db.query_result

func search_by_ids_structure(search):
	var query = "SELECT * FROM merged WHERE ids_structure = ?"
	db.query_with_bindings(query, [search])
	if db.query_result.size() > 0 :
		return "Found match: " + db.query_result[0]["character"]
	else:
		return "No match"
