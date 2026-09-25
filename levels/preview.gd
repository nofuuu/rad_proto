extends Control

@onready var radical_svg: RadicalSVG = $Area/Radical


# ------------------------------------------------------------------------------
# Radical
# ------------------------------------------------------------------------------
func set_character(strokes):
	radical_svg.visible = true
	radical_svg.setup(JSON.parse_string(strokes))
