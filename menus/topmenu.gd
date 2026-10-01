@tool
extends CanvasLayer

@export var custom_text: String = "Default Text":
	set(value):
		custom_text = value
		if label:
			label.text = custom_text
			
@export_multiline("Tutorial text") var info_child_text: String = "":
	set(value):
		info_child_text = value
		var sub_node = get_node_or_null("Info/InfoTextLabel")
		if sub_node:
			sub_node.text = info_child_text

@onready var label = $Label
@onready var info = $Info

func _ready() -> void:
	if label:
		label.text = custom_text
	var sub_node = get_node_or_null("Info/InfoTextLabel")
	if sub_node:
		sub_node.text = info_child_text
