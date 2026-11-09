extends InteractionArea

@onready var split_root = $Split

const EDGE_SIZE = 0.25

# ------------------------------------------------------------------------------
# Reset area
# ------------------------------------------------------------------------------
func reset():
	unset_radical()
	for x in split_root.get_children():
		split_root.remove_child(x)
		x.queue_free()
	split_type = ""
	Signals.composition_changed.emit()
	
# ------------------------------------------------------------------------------
# Unsplit area
# ------------------------------------------------------------------------------
func unsplit():
	if parent == null: return
	var container = parent.split_root.get_child(0)
	container.remove_child(self)
	queue_free()
	var children = container.get_children()
	# More than 1 child, split type downgrades
	if children.size() != 1:
		parent.split_type = downgrade_split(parent.split_type)
		Signals.composition_changed.emit()
		return
	# Only 1 child remains, split collapses
	var survivor = children[0]
	parent.set_radical({"radical": survivor.radical})
	parent.split_type = ""
	parent.split_root.get_child(0).queue_free()
	# Reparents possible children
	if survivor.split_root.get_child_count() > 0:
		var inner = survivor.split_root.get_child(0)
		survivor.split_root.remove_child(inner)
		parent.split_root.add_child(inner)
		for child in inner.get_children():
			child.parent = parent
	survivor.queue_free()
	# Signal
	Signals.composition_changed.emit()
	
func downgrade_split(split):
	match split:
		"⿲": return "⿰"
		"⿳": return "⿱"
		_: return ""
	
# ------------------------------------------------------------------------------
# Parent helper
# ------------------------------------------------------------------------------
func parent_can_expand(zone) -> bool:
	if parent == null : return false
	if parent.split_type == "⿰" and zone not in ["top","bottom"]: return true
	if parent.split_type == "⿱" and zone not in ["left","right"]: return true
	return false
# ------------------------------------------------------------------------------
# Drop
# ------------------------------------------------------------------------------
func _drop_data(pos, data):
	var zone = get_hover_zone(pos)
	# Locked areas cannot split or expand, but center radical can be changed
	if split_locked:
		zone = "center"
	# ----- CENTER -----
	if zone == "center":
		set_radical(data)
		Signals.composition_changed.emit()
		return
	# ----- EXPAND -----
	if parent_can_expand(zone):
		expand_split(data, zone)
		Signals.composition_changed.emit()
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
	Signals.composition_changed.emit()
	return

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
		_:
			print("unknown split type, adding ⿰ HBox for now")
			container = HBoxContainer.new()
	split_root.add_child(container)
	container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for i in count:
		var child = load("res://components/combination/variants/area.tscn").instantiate()
		child.parent = self
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
	var self_index = get_index()
	var insert_index = self_index + 1
	if zone == "left" or zone == "top":
		insert_index = self_index
	var new_area = load("res://components/combination/variants/area.tscn").instantiate()
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
