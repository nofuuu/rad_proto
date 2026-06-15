extends PanelContainer
class_name RadicalItem

@onready var label: RichTextLabel = $RichTextLabel

# This holds the injected data
var data: Radical

var size_tween: Tween

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
	return {"radical":data}

func _on_mouse_entered() -> void:
	# Set the pivot offset to the center so it scales from the middle, not the top-left
	pivot_offset = size / 2.0
	
	# Kill any running tween to prevent stuttering/stacking
	if size_tween and size_tween.is_running():
		size_tween.kill()
		
	size_tween = create_tween()
	# Tweens the scale property to 1.1x over 0.15 seconds using a smooth transition
	size_tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.15)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)


func _on_mouse_exited() -> void:
	if size_tween and size_tween.is_running():
		size_tween.kill()
		
	size_tween = create_tween()
	# Tweens the scale back to normal (1.0)
	size_tween.tween_property(self, "scale", Vector2.ONE, 0.15)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
