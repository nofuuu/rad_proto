extends Control

@onready var preview = $Preview
@onready var game_area = $CombinationArea
var radical_builder = RadicalBuilder.new()
var radical_menu : RadicalMenu = RadicalMenu.new()
@onready var progress : ProgressBar = $ProgressBar

@onready var scatter_area: Control = $ScatterArea

@onready var template = $Preview/CharacterInfo
@onready var pinyin = $Preview/Audio/Pinyin

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_current_level_character.call_deferred()
	load_progressbar()

func load_current_level_character():
	var data = LevelManager.current_char_data
	if data.is_empty() or not data.has("strokes") or data["strokes"] == null:
		push_warning("Level loaded with invalid or missing character data! Redirecting to menu.")
		# Send the player back to level loading menu instead of crashing
		get_tree().change_scene_to_file("res://levels/loadlevels.tscn")
		return
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
	# Add character info
	var template_text = template.text
	var formatted_text = template_text.format({
		"definition": str(LevelManager.current_char_data["definition"]),
	})
	template.text = formatted_text
	pinyin.text = LevelManager.pinyin
	
func load_progressbar():
	progress.max_value = LevelManager.char_queue.size()
	var target_value = LevelManager.current_char_index
	# If this isn't the very first character, start slightly behind for a smooth catch-up effect
	if target_value > 0:
		progress.value = target_value - 1
		var tween = create_tween()
		tween.tween_property(progress, "value", target_value, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	else:
		progress.value = target_value
	
func _next_character():
	if LevelManager.has_next_character():
		LevelManager.advance_character()
		# Reload the level scene for next character
		get_tree().reload_current_scene()
	else:
		# hit last character, animate the progress bar filling to the max
		var tween = create_tween()
		tween.tween_property(progress, "value", progress.max_value, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		# Wait for the fill animation to finish playing
		await tween.finished
		get_tree().change_scene_to_file("res://levels/results.tscn")

func _on_button_pressed() -> void:
	check_win_condition()

func extract_and_scatter_radicals(root_node: Node) -> void:
	for child in scatter_area.get_children():
		child.queue_free()
	var area: Control = game_area.get_node("Area")
	var horizontal_gap: float = 10.0
	var vertical_gap: float = 10.0
	var extracted_radicals: Array = []
	_gather_and_clear_radicals(root_node, extracted_radicals)
	# Get the actual Area position relative to ScatterArea.
	var board_center: Vector2 = scatter_area.size / 2.0
	var board_top_left: Vector2 = board_center - area.size / 2.0
	# -----CREATE RADICAL CARDS-----
	var cards: Array[Control] = []
	for rad_data in extracted_radicals:
		var item: Control = radical_menu.radical_item_scene.instantiate()
		scatter_area.add_child(item)
		item.setup(rad_data)
		# Make sure setup/layout has updated the Control size
		item.reset_size()
		cards.append(item)
	# -----CREATE CARD SLOTS-----
	var safe_slots: Array[Vector2] = []
	var card_width: float = cards[0].size.x
	var card_height: float = cards[0].size.y
	var rows: int = int(floor(area.size.y / (card_height + vertical_gap)))
	for row: int in range(rows):
		var y: float = (
			board_top_left.y
			+ row * (card_height + vertical_gap))
		# Left inner
		safe_slots.append(Vector2(board_top_left.x - horizontal_gap - card_width,y))
		# Left outer
		safe_slots.append(Vector2(board_top_left.x - horizontal_gap * 2.0 - card_width * 2.0,y))
		# Right inner
		safe_slots.append(Vector2(board_top_left.x + area.size.x + horizontal_gap,y))
		# Right outer
		safe_slots.append(Vector2(board_top_left.x + area.size.x + horizontal_gap * 2.0 + card_width,y))

	# Shuffle which card goes where
	safe_slots.shuffle()
	# -----PLACE CARDS-----
	for i: int in range(cards.size()):
		if i < safe_slots.size():
			cards[i].position = safe_slots[i]
	radical_menu._refresh_highlights()
	# ---------------------------------------------------------
	# DUMMY CARDS
	# ---------------------------------------------------------
	for i: int in range(cards.size(), safe_slots.size()):
		var dummy: Control = radical_menu.radical_item_scene.instantiate()
		scatter_area.add_child(dummy)
		var random_rad = radical_builder.build_radical(Database.get_random_radical())
		dummy.setup(random_rad)
		dummy.size = Vector2(
			card_width,
			card_height
		)
		dummy.position = safe_slots[i]

func _gather_and_clear_radicals(node: Node, collector: Array) -> void:
	for child in node.get_children():
		if child is InteractionArea:
			if child.radical != null:
				child.set_meta("correct_radical", child.radical)
				collector.append(child.radical)
				child.unset_radical()
			_gather_and_clear_radicals(child, collector)
		else:
			_gather_and_clear_radicals(child, collector)


## Scans the game layout area to check if all interaction slots match their target answers
func check_win_condition() -> void:
	AudioManager.play_ui("click_003.ogg")
	if _is_character_correct(game_area.get_node("Area")):
		AudioManager.play_sfx("confirmation_002.ogg")
		_next_character()
	else:
		AudioManager.play_sfx("error_004.ogg")
		LevelManager.mistake()

## Recursively parses nodes evaluating player slots against expected meta configurations
func _is_character_correct(node: Node) -> bool:
	for child in node.get_children():
		if child is InteractionArea:
			# Verify if this specific slot was originally assigned an expected radical answer
			if child.has_meta("correct_radical"):
				var expected = child.get_meta("correct_radical")
				var current = child.radical
				# If the slot is completely empty, or the placed radical doesn't match the answer
				if current == null or current != expected:
					return false
		# Continue scanning nested sub-components inside the layout branch
		if not _is_character_correct(child):
			return false
	return true


func _on_skip_button_pressed() -> void:
	AudioManager.play_ui("click_003.ogg")
	LevelManager.skip()
	_next_character()

func _on_play_audio_pressed() -> void:
	AudioManager.play_ui("click_003.ogg")
	AudioManager.play_pinyin(LevelManager.pinyin)
