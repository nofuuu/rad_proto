extends Control
class_name RadicalSVG

var strokes: Array = []

var stroke_color: Color = Color.WHITE
var fit_padding: float = 0.8

func _ready() -> void:
	item_rect_changed.connect(func(): setup_smooth_svg($"."))

func setup(new_strokes):
	strokes = new_strokes
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
