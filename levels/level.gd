extends Control

@onready var preview = $Preview
@onready var game_area = $CombinationArea
var radical_builder = RadicalBuilder.new()
var radical_menu = RadicalMenu.new()

@onready var scatter_area: Control = $ScatterArea

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_current_level_character()

func load_current_level_character():
	# Full character preview
	preview.set_character(LevelManager.current_char_data["strokes"])
	# Radicalbuilder
	radical_builder.build_character_layout(
		LevelManager.get_current_ids(), 
		LevelManager.current_char_data["strokes"], 
		LevelManager.current_char_data["stroke_matches"], 
		game_area.get_node("Area")
	)
	game_area.get_node("Area").set_split_locked(true)
	# Extract radicals from the structure, clear them from inside, and scatter them outside
	extract_and_scatter_radicals(game_area.get_node("Area"))
	
# When player successfully solves character
func _on_character_solved():
	if LevelManager.has_next_character():
		LevelManager.advance_character()
		# Reload the level scene for next character
		get_tree().reload_current_scene()
	else:
		print("You beat all characters!")

func _on_button_pressed() -> void:
	_on_character_solved()

func populate_inventory() -> void:
	# Clear previous
	for child in scatter_area.get_children():
		child.queue_free()
	#Get radicals from database
	var rads = Database.get_radicals()
	# Get the usable bounds of the scatter area
	var area_rect = scatter_area.size
	if area_rect == Vector2.ZERO:
		area_rect = Vector2(400, 400) # Fallback boundary size if not resized yet
	for r in rads:
		var radical = radical_menu.build_radical(r)
		var item = radical_menu.radical_item_scene.instantiate()
		scatter_area.add_child(item)
		item.setup(radical)
		# Generate random positions within the scatter area
		# Adjust margins (e.g., 100px padding) so they don't spawn off-screen
		var random_x = randf_range(50.0, area_rect.x - 150.0)
		var random_y = randf_range(50.0, area_rect.y - 150.0)
		item.position = Vector2(random_x, random_y)
	radical_menu._refresh_highlights()

func extract_and_scatter_radicals(root_node: Node) -> void:
	for child in scatter_area.get_children():
		child.queue_free()
	var extracted_radicals = []
	_gather_and_clear_radicals(root_node, extracted_radicals)
	var area_rect = scatter_area.size
	if area_rect == Vector2.ZERO:
		area_rect = Vector2(400, 400)
	for rad_data in extracted_radicals:
		var item = radical_menu.radical_item_scene.instantiate()
		scatter_area.add_child(item)
		item.setup(rad_data)
		var random_x = randf_range(50.0, area_rect.x - 150.0)
		var random_y = randf_range(50.0, area_rect.y - 150.0)
		item.position = Vector2(random_x, random_y)
	radical_menu._refresh_highlights()

func _gather_and_clear_radicals(node: Node, collector: Array) -> void:
	for child in node.get_children():
		if child is InteractionArea:
			if child.radical != null:
				collector.append(child.radical)
				child.unset_radical()
			_gather_and_clear_radicals(child, collector)
		else:
			_gather_and_clear_radicals(child, collector)
