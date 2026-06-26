extends RadicalMenu

@onready var grid_container: GridContainer = $ScrollContainer/GridContainer

func _ready() -> void:
	populate_inventory()
	Signals.radical_selected.connect(_on_radical_selected)

func populate_inventory() -> void:
	#Clear placeholders
	for child in grid_container.get_children():
		child.queue_free()
	#Get radicals from database
	var rads = Database.get_radicals()
	for r in rads:
		var radical = build_radical(r)
		var item = radical_item_scene.instantiate()
		grid_container.add_child(item)
		item.setup(radical)
	_refresh_highlights()
