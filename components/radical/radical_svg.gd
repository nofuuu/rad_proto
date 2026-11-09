extends Control
class_name RadicalSVG

var strokes: Array = []

var stroke_color: Color = Color.WHITE
var fit_padding: float = 0.8

func _ready() -> void:
	item_rect_changed.connect(func(): setup_smooth_svg($"."))

## Setup using a raw Array of strokes directly
func setup_strokes(new_strokes: Array) -> void:
	strokes = new_strokes
	setup_smooth_svg($".")

## Setup using a full Radical object (handles variants automatically)
func setup(data: Radical) -> void:
	# Check current variant
	if data.current_variant == 0:
		strokes = data.svg_strokes
	else:
		var var_index = data.current_variant - 1
		if var_index >= 0 and var_index < data.variants.size():
			var stroke_json = data.variants[var_index].get("strokes", "")
			if stroke_json is String and not stroke_json.is_empty():
				strokes = JSON.parse_string(stroke_json)
	setup_smooth_svg($".")
	
func setup_smooth_svg(texture_rect: TextureRect) -> void:
	# Size from node
	var target_width: float = size.x
	var target_height: float = size.y
	
	var native_vector_space = 1024
	var paths_content = ""
	for path_data in strokes:
		paths_content += '<path d="%s" fill="white" />' % path_data
	# Flip by Y-axis
	var transformed_content = '<g transform="scale(1, -1) translate(0, -900)">%s</g>' % paths_content
	var full_svg = '<svg xmlns="http://w3.org" viewBox="0 0 %d %d" width="%d" height="%d">%s</svg>' % [
		native_vector_space, native_vector_space,
		target_width, target_height, transformed_content]
	
	var image = Image.new()
	var error = image.load_svg_from_string(full_svg, 1.0)
	if error == OK:
		texture_rect.texture = ImageTexture.create_from_image(image)
