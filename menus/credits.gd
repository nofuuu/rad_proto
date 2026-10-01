extends Control

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/menu.tscn")


func _on_pinyin_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))
