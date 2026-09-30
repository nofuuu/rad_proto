extends Control

var current_mode: int = 0
const MODE_LABELS = ["ALL ▼", "STROKE ▼", "CATEGORY ▼"]
@onready var button: Button = $Mode
@onready var menus: Array = [$MenuContainer/RadicalMenu,
 $MenuContainer/MenuRadicalsByStrokes]


func _ready() -> void:
	button.text = MODE_LABELS[current_mode]
	_update_menu_visibility()

func _on_mode_pressed() -> void:
	AudioManager.play_ui("click_003.ogg")
	current_mode = (current_mode + 1) % 3
	button.text = MODE_LABELS[current_mode]
	_update_menu_visibility()

func _update_menu_visibility() -> void :
	for i in range(menus.size()):
		menus[i].visible = (i == current_mode)
