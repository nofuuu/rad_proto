extends Control

@export var radical_item_scene: PackedScene
@onready var tab_container: TabContainer = $TabContainer

func _ready() -> void:
	populate_inventory()

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
	for r in rads:
		var stroke_count: int = r.strokes
		var target_index = stroke_count - 1
		if target_index >= 0 and target_index < tab_container.get_child_count():
			var grid_container = tab_container.get_child(target_index) as GridContainer
			if grid_container:
				var radical = build_radical(r)
				var item = radical_item_scene.instantiate()
				grid_container.add_child(item)
				item.setup(radical)

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
