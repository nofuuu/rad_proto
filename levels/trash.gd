extends PanelContainer

func _can_drop_data(_pos, data):
	return data.has("source")
	
func _drop_data(_pos, data):
	AudioManager.play_sfx("card-place-4.ogg")
	data["source"].unset_radical()
	data["source"].unsplit()
	Signals.composition_changed.emit()
