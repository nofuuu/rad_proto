extends Button

func _on_pressed() -> void:
	AudioManager.play_ui("click_003.ogg")
	get_tree().change_scene_to_file("res://menus/menu.tscn")
