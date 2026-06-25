extends PanelContainer
class_name InteractionArea

@onready var overlay = $Preview

@onready var radical_svg: RadicalSVG = $Radical

var radical : Radical

# ------------------------------------------------------------------------------
# Radical
# ------------------------------------------------------------------------------
func set_radical(data):
	radical = data.get("radical")
	if radical:
		radical_svg.visible = true
		radical_svg.setup(radical.svg_strokes)
	else:
		unset_radical()
	
func unset_radical():
	radical = null
	radical_svg.visible = false
	
# ------------------------------------------------------------------------------
# Hover
# ------------------------------------------------------------------------------
func _can_drop_data(pos, _data):
	var zone = get_hover_zone(pos)
	show_hover(zone)
	return true

func reset_overlay():
	if overlay == null:
		return
	overlay.visible = true
	overlay.custom_minimum_size = Vector2.ZERO
	overlay.size_flags_horizontal = SIZE_FILL
	overlay.size_flags_vertical = SIZE_FILL

func hide_overlay():
	if overlay:
		overlay.visible = false

func _on_mouse_exited() -> void:
	hide_overlay()

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		hide_overlay()
		
func _get_drag_data(_at_position: Vector2) -> Variant:
	var preview = duplicate()
	preview.modulate.a = 0.2
	set_drag_preview(preview)
	return {
		"radical":radical,
		"source":self
	}

# ------------------------------------------------------------------------------
# Override in children
# ------------------------------------------------------------------------------
func show_hover(_zone: String):
	pass
	
func get_hover_zone(_pos: Vector2) -> String:
	return ""
