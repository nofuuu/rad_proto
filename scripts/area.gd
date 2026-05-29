extends PanelContainer

signal composition_changed

@onready var overlay = $Preview
@onready var label = $RichTextLabel
@onready var split_root = $Split

const EDGE_SIZE = 0.25

var radical : Radical
var split_type : String = ""

var parent : Node = null

# ------------------------------------------------------------------------------
# Radical
# ------------------------------------------------------------------------------
func set_radical(data):
	radical = data.get("radical")
	if radical:
		label.visible = true
		label.text = radical.character
	else:
		unset_radical()
	
func unset_radical():
	radical = null
	label.visible = false
	label.text = ""
	
# ------------------------------------------------------------------------------
# Parent helper
# ------------------------------------------------------------------------------
func parent_can_expand() -> bool:
	return parent != null and parent.split_type in ["⿰", "⿱"]

# ------------------------------------------------------------------------------
# Drag & Drop
# ------------------------------------------------------------------------------
func _get_drag_data(_at_position: Vector2) -> Variant:
	var preview = duplicate()
	preview.modulate.a = 0.2
	set_drag_preview(preview)
	return {
		"radical":radical,
		"source":self
	}

func _can_drop_data(pos, _data):
	show_hover(get_hover_zone(pos))
	return true

func _drop_data(pos, data):
	var zone = get_hover_zone(pos)
	# ----- CENTER -----
	if zone == "center":
		set_radical(data)
		composition_changed.emit()
		return
	# ----- EXPAND -----
	if parent_can_expand():
		expand_split(data, zone)
		composition_changed.emit()
		return
	# ----- SPLIT -----
	var old_radical = {"radical":radical}
	unset_radical()
	match zone:
		"left","right":
			create_split("⿰")
		"top","bottom":
			create_split("⿱")
	# Setting radicals in split area slots
	match zone:
		"left","top":
			split_root.get_child(0).get_child(0).set_radical(data)
			split_root.get_child(0).get_child(1).set_radical(old_radical)
		"right", "bottom":
			split_root.get_child(0).get_child(1).set_radical(data)
			split_root.get_child(0).get_child(0).set_radical(old_radical)
	# Send signal
	composition_changed.emit()
	return
	
func _on_child_changed():
	composition_changed.emit()

# ------------------------------------------------------------------------------
# Split
# ------------------------------------------------------------------------------
func clear_structure():
	for c in split_root.get_children():
		c.queue_free()
	split_type = ""
	unset_radical()

func create_split(type : String, count:=2):
	clear_structure()
	split_type = type
	var container
	match type:
		"⿰","⿲":
			container = HBoxContainer.new()
		"⿱","⿳":
			container = VBoxContainer.new()
	split_root.add_child(container)
	container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for i in count:
		var child = preload("res://scenes/area.tscn").instantiate()
		child.parent = self
		child.composition_changed.connect(_on_child_changed)
		container.add_child(child)

# ------------------------------------------------------------------------------
# Split expand
# ------------------------------------------------------------------------------
func expand_split(data: Dictionary, zone : String):
	match parent.split_type:
		"⿰" : parent.split_type = "⿲"
		"⿱" : parent.split_type = "⿳"
	if parent.split_root.get_child_count() == 0:
		return
	var container = parent.split_root.get_child(0)
	var insert_index = container.get_child_count()
	if zone == "left" or zone == "top":
		insert_index = 0
	var new_area = preload("res://scenes/area.tscn").instantiate()
	new_area.composition_changed.connect(_on_child_changed)
	new_area.parent = parent
	container.add_child(new_area)
	container.move_child(new_area, insert_index)
	new_area.set_radical(data)
# ------------------------------------------------------------------------------
# Hover zone
# ------------------------------------------------------------------------------
func get_hover_zone(pos):
	var x = pos.x / size.x
	var y = pos.y / size.y
	if x < EDGE_SIZE:
		return "left"
	if x > 1.0 - EDGE_SIZE:
		return "right"
	if y < EDGE_SIZE:
		return "top"
	if y > 1.0 - EDGE_SIZE:
		return "bottom"
	return "center"

# ------------------------------------------------------------------------------
# Hover preview
# ------------------------------------------------------------------------------
func show_hover(zone):
	overlay.visible = true
	var dynamic_width = size.x * EDGE_SIZE
	var dynamic_height = size.y * EDGE_SIZE
	overlay.custom_minimum_size = Vector2.ZERO
	overlay.size_flags_vertical = SIZE_FILL
	overlay.size_flags_horizontal = SIZE_FILL
	match zone:
		"left":
			overlay.custom_minimum_size.x = dynamic_width
			overlay.size_flags_horizontal = SIZE_SHRINK_BEGIN
		"right":
			overlay.custom_minimum_size.x = dynamic_width
			overlay.size_flags_horizontal = SIZE_SHRINK_END
		"top":
			overlay.custom_minimum_size.y = dynamic_height
			overlay.size_flags_vertical = SIZE_SHRINK_BEGIN
		"bottom":
			overlay.custom_minimum_size.y = dynamic_height
			overlay.size_flags_vertical = SIZE_SHRINK_END

func _on_mouse_exited() -> void:
	overlay.visible = false

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		overlay.visible = false

# ------------------------------------------------------------------------------
# IDS Serialization
# ------------------------------------------------------------------------------
func serialize() -> String:
	if split_type == "":
		if radical != null:
			return radical.character
		else:
			return ""
	var ids = split_type
	for c in split_root.get_child(0).get_children():
		ids += c.serialize()
	
	return ids
