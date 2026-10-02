extends Control

func _on_text_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))
