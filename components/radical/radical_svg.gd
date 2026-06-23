extends Control
class_name RadicalSVG

var strokes: Array = []

var stroke_color: Color = Color.WHITE
var fit_padding: float = 0.8

func _ready() -> void:
	item_rect_changed.connect(queue_redraw)


func setup(new_strokes):
	strokes = new_strokes
	setup_smooth_svg($".")

func setup_smooth_svg(texture_rect: TextureRect) -> void:
	# 1. Rebuild a valid SVG string from your paths
	var svg_width = 1024
	var svg_height = 1024
	var paths_content = ""
	
	for path_data in strokes:
		paths_content += '<path d="%s" fill="white" />' % path_data
		
	var full_svg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 %d %d" width="%d" height="%d">%s</svg>' % [
		svg_width, svg_height, svg_width, svg_height, paths_content
	]
	
	# 2. Turn the string into a Godot Image
	var image = Image.new()
	var error = image.load_svg_from_string(full_svg, 0.035)
	if error == OK:
		texture_rect.texture = ImageTexture.create_from_image(image)
		
		# 3. FORCE GODOT TO SMOOTH OUT THE AGGRESSIVE EDGES
		#texture_rect.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
