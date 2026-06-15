extends PanelContainer

func _can_drop_data(_pos, data):
	return data.has("source")
	
func _drop_data(_pos, data):
	data["source"].unset_radical()
	data["source"].unsplit()
	Signals.composition_changed.emit()
