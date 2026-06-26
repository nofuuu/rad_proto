extends Node

var selected_radical = null

signal composition_changed
signal reset_combination_area
signal radical_selected(radical_data)

func select_radical(radical_data) -> void:
	selected_radical = radical_data
	radical_selected.emit(radical_data)
