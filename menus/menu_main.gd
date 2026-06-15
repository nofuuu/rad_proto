extends Control

@onready var button_tutorial = $Node/Button_Tutorial
@onready var button_levels = $Node/Button_Levels
@onready var button_sandbox = $Node/Button_Sandbox

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_button_tutorial_pressed() -> void:
	print("tutorial pressed")

func _on_button_levels_pressed() -> void:
	print("levels pressed")

func _on_button_sandbox_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/sandbox.tscn")
