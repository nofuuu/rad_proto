extends Control
@onready var textedit = $TabContainer/CUSTOM/TextEdit
@onready var preview = $Label/ScrollContainer/Preview
@onready var label = $Label
@onready var file_dialog = $FileDialog
@onready var start_button = $StartGame
@onready var preset_container = $TabContainer/PRESETS/ScrollContainer/PresetContainer

const ROOT_SCENE = preload("res://levels/preview_area.tscn")
const PRESETS_FOLDER_PATH = "res://levels/presets/"
var radical_builder = RadicalBuilder.new()

var valid_char_queue: Array[String] = []

func _ready() -> void:
	update_start_button_state()
	_populate_preset_buttons()
	var scroll_container = $TabContainer/PRESETS/ScrollContainer
	scroll_container.add_theme_constant_override("scrollbar_margin", 16)
	
## Scans the presets directory and generates interactive selection buttons.
func _populate_preset_buttons() -> void:
	# Clear placeholders
	for child in preset_container.get_children():
		child.queue_free()
	if not DirAccess.dir_exists_absolute(PRESETS_FOLDER_PATH):
		push_warning("Presets folder directory missing at: " + PRESETS_FOLDER_PATH)
		return
	var dir := DirAccess.open(PRESETS_FOLDER_PATH)
	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		
		while file_name != "":
			# Only target plain text asset files, skipping Godot system import files
			if not dir.current_is_dir() and file_name.ends_with(".txt"):
				var full_file_path := PRESETS_FOLDER_PATH + file_name
				_create_preset_button(file_name, full_file_path)
				
			file_name = dir.get_next()
		dir.list_dir_end()
		
## Instantiates a mobile-friendly button and binds its file reading behavior.
func _create_preset_button(display_name: String, target_file_path: String) -> void:
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(128, 64)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# Clean up filename for UI label ("level_1.txt" -> "LEVEL 1")
	btn.text = display_name.get_basename().to_upper().replace("_", " ")
	btn.pressed.connect(func():
		AudioManager.play_ui("click_003.ogg")
		_load_preset_file(target_file_path)
	)
	preset_container.add_child(btn)
	
## Reads a selected preset string layout and forwards it to the parser.
func _load_preset_file(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file:
		var file_contents := file.get_as_text()
		file.close()
		# Automatically update TextEdit box view to match the loaded file content
		textedit.text = file_contents
		process_text(file_contents)
	else:
		push_error("Failed to read preset asset text file path: " + path)

func process_text(raw_text: String) -> void:
	# Clear previosly loaded preview
	for c in preview.get_children():
		c.queue_free()
	valid_char_queue.clear()
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
	label.text = "PREVIEW - UNIQUE CHARACTERS: " + str(unique_characters.size())
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
	root_area.set_split_locked(true)

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
		textedit.text = file_contents
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
