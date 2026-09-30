@tool
extends Control

@export var custom_text: String = "Default Text":
	set(value):
		custom_text = value
		if label:
			label.text = custom_text

@onready var label = $Label

func _ready() -> void:
	label.text = custom_text
