extends Button

func _on_pressed() -> void:
	Signals.reset_combination_area.emit()
