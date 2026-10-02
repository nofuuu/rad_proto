extends Control

@onready var Hider = $Hide
@onready var SettingsPanel = $Panel

var settings_toggled:bool = false
	
func toggle_settings(t:bool):
	if SettingsPanel:
		SettingsPanel.visible = t
	if Hider:
		Hider.visible = t

func _on_settings_pressed() -> void:
	AudioManager.play_ui("click_003.ogg")
	settings_toggled = not settings_toggled
	toggle_settings(settings_toggled)

func _on_hide_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		AudioManager.play_ui("click_003.ogg")
		settings_toggled = not settings_toggled
		toggle_settings(settings_toggled)
