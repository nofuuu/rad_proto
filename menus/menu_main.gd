extends Control

@onready var button_tutorial = $Buttons/Button_Tutorial
@onready var button_levels = $Buttons/Button_Levels
@onready var button_sandbox = $Buttons/Button_Sandbox

@onready var lstart: Label = $Title/Label
@onready var labels: Array[Label] = [$"Title/Control/1",$"Title/Control/2",$"Title/Control/3",$"Title/Control/4"]
@onready var lend: Label = $Title/Label2

@export var slide_offset: float = 300.0
@export var duration: float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	show_labels_sequentially()

func _on_button_tutorial_pressed() -> void:
	print("tutorial pressed")

func _on_button_levels_pressed() -> void:
	print("levels pressed")

func _on_button_sandbox_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/sandbox.tscn")


func show_labels_sequentially() -> void:
	var tween: Tween = create_tween()
	lstart.modulate.a = 0.0
	lend.modulate.a = 0.0
	# Animate start
	tween.tween_property(lstart, "modulate:a", 1.0, duration)\
		.set_trans(Tween.TRANS_LINEAR)\
		.set_ease(Tween.EASE_IN_OUT)
	# Animate hanzi
	var stagger_delay: float = duration * 0.35
	for i in range(labels.size()):
		var label = labels[i]
		if label == null:
			continue
		label.modulate.a = 0.0
		var final_position: Vector2 = label.position
		label.position.y -= slide_offset
		var start_delay: float = (duration * 0.5) + (i * stagger_delay)
		tween.parallel().tween_property(label, "position:y", final_position.y, duration)\
			.set_trans(Tween.TRANS_BOUNCE)\
			.set_ease(Tween.EASE_OUT)\
			.set_delay(start_delay)
		tween.parallel().tween_property(label, "modulate:a", 1.0, duration * 0.6)\
			.set_trans(Tween.TRANS_CUBIC)\
			.set_ease(Tween.EASE_OUT)\
			.set_delay(start_delay)
	# Animate end
	var end_delay: float = (duration * 0.5) + (labels.size() * stagger_delay)
	tween.tween_property(lend, "modulate:a", 1.0, duration * 0.5)\
		.set_trans(Tween.TRANS_LINEAR)\
		.set_ease(Tween.EASE_IN_OUT)\
