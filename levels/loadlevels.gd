extends Control
@onready var textedit = $TextEdit
@onready var preview = $Label/Preview
@onready var label = $Label

const ROOT_SCENE = preload("res://levels/preview_area.tscn")
var radical_builder = RadicalBuilder.new()

var valid_char_queue: Array[String] = []

func _on_button_pressed() -> void:
	AudioManager.play_ui("click_003.ogg")
	# Clear previosly loaded preview
	for c in preview.get_children():
		c.queue_free()
	# Clear whitespaces
	var regex = RegEx.new()
	regex.compile("\\s+")
	var search = regex.sub(textedit.text, "", true)
	# Get unique characters to dictionary
	var unique_characters = {}
	for character in search:
		unique_characters[character] = true
	for character in unique_characters:
		var found = Database.get_character_data(character)
		if found["character"] == null or found["character"] == "":
			print("character not found - ", character)
			continue
		valid_char_queue.append(character)
		build(found)
	label.text = "Preview - Unique Characters: " + str(unique_characters.size())

func build(data: Dictionary):
	var root = ROOT_SCENE.instantiate()
	preview.add_child(root)
	var root_area = root.get_node("Area")
	radical_builder.build_character_layout(
		data["decomposition"], 
		data["strokes"], 
		data["stroke_matches"], 
		root_area
	)

func _on_start_game_pressed() -> void:
	AudioManager.play_ui("click_003.ogg")
	if valid_char_queue.is_empty():
		print("No valid characters loaded to play!")
		return
	# Save valid characters to level manager
	LevelManager.reset_queue(valid_char_queue)
	get_tree().change_scene_to_file("res://levels/level.tscn")
