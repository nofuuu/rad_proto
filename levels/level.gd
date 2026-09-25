extends Control

@onready var preview = $Preview
@onready var game_area = $CombinationArea
var radical_builder = RadicalBuilder.new()

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
