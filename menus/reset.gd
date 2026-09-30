extends Button

func _on_pressed() -> void:
	AudioManager.play_ui("click_003.ogg")
	Signals.reset_combination_area.emit()
