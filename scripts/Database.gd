extends Node
var db : SQLite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	db = SQLite.new()
	db.path = "res://data/dictionary_combined.db"
	db.read_only = true
	if db.open_db():
		var query = "SELECT * FROM merged WHERE character = '你' LIMIT 1;"
		db.query(query)
		print("Query Results: ", db.query_result[0]["pinyin"])
	else:
		print("Failed to open DB")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func get_radicals():
	var query = "SELECT * FROM radicals"
	db.query(query)
	return db.query_result
