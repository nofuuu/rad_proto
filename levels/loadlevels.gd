extends Control
@onready var textedit = $TextEdit
@onready var preview = $Label/ScrollContainer/Preview
@onready var label = $Label
@onready var file_dialog = $FileDialog
@onready var start_button = $StartGame

const ROOT_SCENE = preload("res://levels/preview_area.tscn")
var radical_builder = RadicalBuilder.new()

var valid_char_queue: Array[String] = []

func _ready() -> void:
	update_start_button_state()

func process_text(raw_text: String) -> void:
	# Clear previosly loaded preview
	for c in preview.get_children():
		c.queue_free()
	# Clear whitespaces
	var regex = RegEx.new()
	regex.compile("\\s+")
	var search = regex.sub(raw_text, "", true)
	# Get unique characters to dictionary
	var unique_characters = {}
	for character in search:
		unique_characters[character] = true
	for character in unique_characters:
		var found = Database.get_character_data(character)
		if not found.has("character") or found["character"] == null or found["character"] == "":
			print("character not found - ", character)
			continue
		valid_char_queue.append(character)
		build(found)
	label.text = "Preview - Unique Characters: " + str(unique_characters.size())
	update_start_button_state()

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

func _on_button_pressed() -> void:
	AudioManager.play_ui("click_003.ogg")
	process_text(textedit.text)
	
func _on_load_file_pressed() -> void:
	AudioManager.play_ui("click_003.ogg")
	file_dialog.popup_centered()
	
func _on_file_dialog_file_selected(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var file_contents = file.get_as_text()
		file.close()
		process_text(file_contents)
	else:
		print("Failed to open file at path: ", path)


func update_start_button_state() -> void:
	start_button.disabled = valid_char_queue.is_empty()

func _on_start_game_pressed() -> void:
	AudioManager.play_ui("click_003.ogg")
	if valid_char_queue.is_empty():
		print("No valid characters loaded to play!")
		return
	# Save valid characters to level manager
	LevelManager.reset_queue(valid_char_queue)
	get_tree().change_scene_to_file("res://levels/level.tscn")
