extends PanelContainer
class_name RadicalItem

@onready var radical: RadicalSVG = $Radical
var data: Radical

var size_tween: Tween

# Call this function right after instantiating the scene
func setup(radical_data: Radical) -> void:
	data = radical_data
	self.tooltip_text = data.radical_name
	# Wait for the node to be ready in the tree before setting UI elements
	if not is_node_ready():
		await ready
	radical.setup(data.svg_strokes)

func _get_drag_data(_at_position: Vector2) -> Variant:
	var preview = duplicate()
	preview.modulate.a = 0.2
	set_drag_preview(preview)
	return {"radical":data}

# ------------------------------------------------------------------------------
# Hover over animation
# ------------------------------------------------------------------------------
func _on_mouse_entered() -> void:
	# Set the pivot offset to the center so it scales from the middle, not the top-left
	pivot_offset = size / 2.0
	
	# Kill any running tween to prevent stuttering/stacking
	if size_tween and size_tween.is_running():
		size_tween.kill()
		
	size_tween = create_tween()
	# Tweens the scale property to 1.1x over 0.15 seconds using a smooth transition
	size_tween.tween_property(self, "scale", Vector2(1.15, 1.15), 0.15)\
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

# ------------------------------------------------------------------------------
# Highlight selected
# ------------------------------------------------------------------------------
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		AudioManager.play_ui("click_003.ogg")
		if Signals.selected_radical != null and Signals.selected_radical.radical_name == data.radical_name:
			Signals.select_radical(null)
		else:
			Signals.select_radical(data)
		
func highlight_item(is_selected: bool) -> void:
	if is_selected:
		self.modulate = Color(1.5, 1.5, 1.5) # Make it glow slightly
	else:
		self.modulate = Color(1, 1, 1) # Normal
