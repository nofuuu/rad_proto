@tool
extends CanvasLayer

@export var custom_text: String = "":
	set(value):
		custom_text = value
		if InfoText:
			InfoText.text = custom_text

func _ready() -> void:
	InfoText.text = custom_text


@onready var Hider = $Hide
@onready var InfoText = $InfoTextLabel

var info_toggled:bool = false
	
func toggle_info(t:bool):
	if InfoText:
		InfoText.visible = t
	if Hider:
		Hider.visible = t


func _on_hide_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		AudioManager.play_ui("click_003.ogg")
		info_toggled = not info_toggled
		toggle_info(info_toggled)


func _on_info_pressed() -> void:
	AudioManager.play_ui("click_003.ogg")
	info_toggled = not info_toggled
	toggle_info(info_toggled)
