extends Control

@export var radical_item_scene: PackedScene
@onready var grid_container: GridContainer = $"."

func _ready() -> void:
	populate_inventory()

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
	return radical
	
func add_variant(radical: Radical, rad, num: int):
	var variant = rad.get("variant_%d" % num)
	var pos = rad.get("variant_%d_pos" % num)
	radical.variants.append({
		"var": variant,
		"pos": pos
	})
