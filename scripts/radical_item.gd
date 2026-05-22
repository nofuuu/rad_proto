extends PanelContainer
class_name RadicalItem

@onready var label: Label = $Label

# This holds the injected data
var data: Radical

# Call this function right after instantiating the scene
func setup(radical_data: Radical) -> void:
	data = radical_data
	# Wait for the node to be ready in the tree before setting UI elements
	if not is_node_ready():
		await ready
	label.text = data.character

func _get_drag_data(_at_position: Vector2) -> Variant:
	var preview = duplicate()
	preview.modulate.a = 0.2
	set_drag_preview(preview)
	return data
