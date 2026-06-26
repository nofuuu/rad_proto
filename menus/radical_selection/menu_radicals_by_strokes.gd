extends RadicalMenu

@onready var tab_container: TabContainer = $TabContainer
@onready var grid_14_up : GridContainer = $"TabContainer/12+"

func _ready() -> void:
	rename_tabs()
	populate_inventory()
	Signals.radical_selected.connect(_on_radical_selected)
	
func rename_tabs() -> void:
	for i in range(11):
		tab_container.set_tab_title(i, (" " + str(i+1) + " "))

func populate_inventory() -> void:
	# Clear placeholders
	for c in tab_container.get_children():
		var grid = c as GridContainer
		if grid:
			for item in grid.get_children():
				item.queue_free()
	# Get radicals from database
	var rads = Database.get_radicals()
	# Sort them to grids
	var label_helper: int = 11
	for r in rads:
		var radical = build_radical(r)
		var item = radical_item_scene.instantiate()
		var stroke_count: int = r.strokes
		if stroke_count > 11 :
			if not stroke_count == label_helper:
				print(str(label_helper) + "  " + str(stroke_count))
				label_helper = stroke_count
				var label = Label.new()
				label.text = (str(stroke_count) + ":")
				label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				grid_14_up.add_child(label)
			grid_14_up.add_child(item)
			item.setup(radical)
			continue
		var target_index = stroke_count - 1
		if target_index >= 0 and target_index < tab_container.get_child_count():
			var grid_container = tab_container.get_child(target_index) as GridContainer
			if grid_container:
				grid_container.add_child(item)
				item.setup(radical)
	_refresh_highlights()
