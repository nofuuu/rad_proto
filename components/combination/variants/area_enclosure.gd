extends InteractionArea

@onready var inner:InteractionArea = $Inner

const INNER_MARGIN = 0.25

var outer_radical : Radical

func _ready() -> void:
	inner.custom_minimum_size.x = size.x - (size.x * INNER_MARGIN) * 2.0
	inner.custom_minimum_size.y = size.y - (size.y * INNER_MARGIN) * 2.0
	inner.parent = self

func _drop_data(pos, data):
	var zone = get_hover_zone(pos)
	# ----- OUTER -----
	if zone == "outer":
		set_radical(data)
		Signals.composition_changed.emit()
		return

# ------------------------------------------------------------------------------
# Hover
# ------------------------------------------------------------------------------
func get_hover_zone(pos: Vector2) -> String:
	var x = pos.x / size.x
	var y = pos.y / size.y
	
	if (
		x > INNER_MARGIN
		and x < 1.0 - INNER_MARGIN
		and y > INNER_MARGIN
		and y < 1.0 - INNER_MARGIN
	):
		return "inner"
	return "outer"

func show_hover(zone: String):
	overlay.visible = true
	var dynamic_width = size.x * INNER_MARGIN
	var dynamic_height = size.y * INNER_MARGIN
	overlay.custom_minimum_size = Vector2.ZERO
	overlay.size_flags_vertical = SIZE_FILL
	overlay.size_flags_horizontal = SIZE_FILL
	if zone == "inner":
		overlay.custom_minimum_size = Vector2(
			size.x - dynamic_width * 2.0,
			size.y - dynamic_height * 2.0
		)
		overlay.size_flags_horizontal = SIZE_SHRINK_CENTER
		overlay.size_flags_vertical = SIZE_SHRINK_CENTER
	else:
		pass
		

# ------------------------------------------------------------------------------
# Unsplit
# ------------------------------------------------------------------------------
func unsplit():
	var scene_parent = get_parent()
	if scene_parent == null:
		return
	var my_index = get_index()
	inner.owner = null
	inner.custom_minimum_size = custom_minimum_size
	inner.size_flags_horizontal = size_flags_horizontal
	inner.size_flags_vertical = size_flags_vertical
	inner.reparent(scene_parent)
	scene_parent.move_child(inner, my_index)
	inner.position = position
	if inner is InteractionArea:
		inner.parent = self.parent
	queue_free()
	Signals.composition_changed.emit()
