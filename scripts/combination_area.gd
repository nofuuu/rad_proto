extends Control
@onready var label = $Label
@onready var area = $Area

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area.composition_changed.connect(_on_composition_changed)

func _on_composition_changed():
	var ids = area.serialize()
	label.text = ids
	Database.search_by_ids_structure(ids)
