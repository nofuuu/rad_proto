extends Control

const BUS_NAME = "Master"
var bus_index: int

func _ready() -> void:
	bus_index = AudioServer.get_bus_index(BUS_NAME)

func _on_h_slider_value_changed(value: float) -> void:
	if value <= -39:
		AudioServer.set_bus_mute(bus_index, true)
	else:
		AudioServer.set_bus_mute(bus_index, false)
		AudioServer.set_bus_volume_db(bus_index, value)
