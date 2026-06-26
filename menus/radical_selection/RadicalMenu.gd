extends RadicalBuilder
class_name RadicalMenu

var radical_item_scene: PackedScene = preload("res://components/radical/radical.tscn")

var currently_selected_radical = null

func _on_radical_selected(radical_data) -> void:
	currently_selected_radical = radical_data
	_refresh_highlights()

# ------------------------------------------------------------------------------
# Highlight selected
# ------------------------------------------------------------------------------
func _refresh_highlights() -> void:
	var target_data = Signals.selected_radical
	if has_node("ScrollContainer/GridContainer"):
		highlight_selected(get_node("ScrollContainer/GridContainer"), target_data)
	elif has_node("TabContainer"):
		highlight_selected(get_node("TabContainer"), target_data)
		
func highlight_selected(node: Node, radical_data) -> void:
	for child in node.get_children():
		if child.has_method("highlight_item"):
			if radical_data == null:
				child.highlight_item(false)
			elif child.data == null:
				child.highlight_item(false)
			else:
				child.highlight_item(child.data.radical_name == radical_data.radical_name)
		highlight_selected(child, radical_data)
