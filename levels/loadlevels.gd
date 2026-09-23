extends Control
@onready var textedit = $TextEdit
@onready var preview = $Label/Preview
@onready var label = $Label

const ROOT_SCENE = preload("res://levels/preview_area.tscn")
var radical_builder = RadicalBuilder.new()

const IDS_OPERATORS = {
	"⿰": 2,
	"⿱": 2,
	"⿲": 3,
	"⿳": 3,
	"⿴": 2,
	"⿵": 2,
	"⿶": 2,
	"⿷": 2,
	"⿸": 2,
	"⿹": 2,
	"⿺": 2,
	"⿻": 2,
}

func _on_button_pressed() -> void:
	# Clear previosly loaded preview
	for c in preview.get_children():
		c.queue_free()
	# Clear whitespaces
	var regex = RegEx.new()
	regex.compile("\\s+")
	var search = regex.sub(textedit.text, "", true)
	# Get unique characters to dictionary
	var unique_characters = {}
	for character in search:
		unique_characters[character] = true
	for character in unique_characters:
		var found = Database.get_ids_from_character(character)
		if found == "":
			print("character not found - ", character)
			continue
		build(found)
	label.text = "Preview - Unique Characters: " + str(unique_characters.size())

func build(ids: String):
	var root = ROOT_SCENE.instantiate()
	preview.add_child(root)
	#root.custom_minimum_size = Vector2(128, 128)
	var root_area = root.get_node("Area")
	var area_boundary = root.get_node("Boundary")
	#root_area.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	#root_area.custom_minimum_size = Vector2(128, 128)
	#area_boundary.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	#area_boundary.custom_minimum_size = Vector2(132, 132)
	parse(ids, 0, root_area)
	
	
func parse(chars: String, index: int, area: InteractionArea) -> int:
	var char = chars[index]
	# Character
	if not IDS_OPERATORS.has(char):
		var rad = Database.get_radical(char)
		if rad == null:
			push_error("No radical found for: " + char)
			return index + 1
		var radical = radical_builder.build_radical(rad)
		area.set_radical({"radical": radical})
		return index + 1
	# Split
	var count = IDS_OPERATORS[char]
	area.create_split(char, count)
	var container = area.split_root.get_child(0)
	var next_index = index + 1
	for i in count:
		var child = container.get_child(i)
		next_index = parse(chars, next_index, child)
	return next_index
