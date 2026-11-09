extends Control
@onready var radical_name: Label = $HBoxContainer/VBoxContainer/Name
@onready var pinyin: Label = $HBoxContainer/VBoxContainer2/Pinyin
@onready var radical:RadicalSVG = $HBoxContainer/VBoxContainer/Radical

func _ready() -> void:
	_empty_info()
	Signals.radical_selected.connect(_on_radical_selected)

func _on_play_audio_pressed() -> void:
	AudioManager.play_ui("click_003.ogg")
	if not Signals.selected_radical:
		print("Play audio skipped: No radical is currently selected.")
		return
	AudioManager.play_pinyin(Signals.selected_radical.pinyin)

func _empty_info() -> void:
	radical_name.text = ""
	pinyin.text = ""
	radical.setup_strokes([])

func _on_radical_selected(data):
	if not data:
		_empty_info()
		return
	radical_name.text = data.radical_name
	pinyin.text = data.pinyin
	radical.setup_strokes(data.svg_strokes)
