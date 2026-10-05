extends Control

@onready var template = $Text


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var template_text = template.text
	# Fill in the placeholders using a dictionary
	var formatted_text = template_text.format({
		"skipped": str(LevelManager.skipped),
		"skipped_chars": str(LevelManager.skipped_chars),
		"mistakes": str(LevelManager.mistakes),
		"mistake_chars": str(LevelManager.mistake_chars)
	})
	template.text = formatted_text
