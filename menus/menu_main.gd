extends Control

@onready var button_levels = $Buttons/Button_Levels
@onready var button_sandbox = $Buttons/Button_Sandbox

@onready var lstart: Label = $Label
@onready var lend: Label = $Label2

@export var slide_offset: float = 300.0
@export var duration: float = 0.8

@onready var char1a = $Char1A
@onready var char1b = $Char1B
@onready var char2a = $Char2A
@onready var char2b = $Char2B
@onready var chars: Array[Control] = [$Char1A,$Char1B,$Char2A,$Char2B]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	show_labels_sequentially()
	show_hanzi()

func show_hanzi():
	var char_data = Database.get_character_data("汉")
	var strokes = char_data["strokes"]
	var stroke_matches = char_data["stroke_matches"]
	var components = group_strokes_by_matches(strokes, stroke_matches)
	char1a.set_character(JSON.stringify(components[0]))
	char1b.set_character(JSON.stringify(components[1]))
	char_data = Database.get_character_data("字")
	strokes = char_data["strokes"]
	stroke_matches = char_data["stroke_matches"]
	components = group_strokes_by_matches(strokes, stroke_matches)
	char2a.set_character(JSON.stringify(components[0]))
	char2b.set_character(JSON.stringify(components[1]))

func group_strokes_by_matches(strokes, stroke_matches) -> Array:
	var s = JSON.parse_string(strokes)
	var m = JSON.parse_string(stroke_matches)
	var grouped: Array = []
	for i in range(s.size()):
		var group_id = m[i][0] if m[i] is Array else m[i]
		while grouped.size() <= group_id:
			grouped.append([])
		grouped[group_id].append(s[i])
	return grouped

func _on_button_levels_pressed() -> void:
	AudioManager.play_ui("click_003.ogg")
	get_tree().change_scene_to_file("res://levels/loadlevels.tscn")

func _on_button_sandbox_pressed() -> void:
	AudioManager.play_ui("click_003.ogg")
	get_tree().change_scene_to_file("res://levels/sandbox.tscn")
	
func _on_button_credits_pressed() -> void:
	AudioManager.play_ui("click_003.ogg")
	get_tree().change_scene_to_file("res://menus/credits.tscn")

func show_labels_sequentially() -> void:
	var tween: Tween = create_tween()
	lstart.modulate.a = 0.0
	lend.modulate.a = 0.0
	# Animate start
	tween.tween_property(lstart, "modulate:a", 1.0, duration)\
		.set_trans(Tween.TRANS_LINEAR)\
		.set_ease(Tween.EASE_IN_OUT)
	# Animate hanzi
	var stagger_delay: float = duration * 0.35
	for i in range(chars.size()):
		var label = chars[i]
		if label == null:
			continue
		label.modulate.a = 0.0
		var final_position: Vector2 = label.position
		label.position.y -= slide_offset
		var start_delay: float = (duration * 0.5) + (i * stagger_delay)
		tween.parallel().tween_property(label, "position:y", final_position.y, duration)\
			.set_trans(Tween.TRANS_BOUNCE)\
			.set_ease(Tween.EASE_OUT)\
			.set_delay(start_delay)
		tween.parallel().tween_property(label, "modulate:a", 1.0, duration * 0.6)\
			.set_trans(Tween.TRANS_CUBIC)\
			.set_ease(Tween.EASE_OUT)\
			.set_delay(start_delay)
	# Animate end
	tween.tween_property(lend, "modulate:a", 1.0, duration * 0.5)\
		.set_trans(Tween.TRANS_LINEAR)\
		.set_ease(Tween.EASE_IN_OUT)\
