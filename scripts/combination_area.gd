extends Control
@onready var idsstring = $IDS_String
@onready var matchstring = $Match
@onready var area = $Area

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signals.connect("composition_changed", _on_composition_changed)
	Signals.connect("reset_combination_area", _reset_combination_area)

func _on_composition_changed():
	var ids = area.serialize()
	idsstring.text = ids
	matchstring.text = Database.search_by_ids_structure(ids)
	
func _reset_combination_area():
	area.reset()
