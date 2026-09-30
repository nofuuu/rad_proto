extends Control


@onready var music_slider: HSlider = $VBoxContainer/Music/MusicSlider
@onready var master_slider: HSlider = $VBoxContainer/Master/MasterSlider
@onready var pinyin_slider: HSlider = $VBoxContainer/Pinyin/PinyinSlider
@onready var sfx_slider: HSlider = $VBoxContainer/SFX/SFXSlider

func _ready():
	music_slider.value = AudioManager.get_bus_volume("Music")
	master_slider.value = AudioManager.get_bus_volume("Master")
	sfx_slider.value = AudioManager.get_bus_volume("SFX")
	pinyin_slider.value = AudioManager.get_bus_volume("Pinyin")
		
func _on_music_slider_value_changed(value: float) -> void:
	AudioManager.set_bus_volume("Music", value)

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioManager.set_bus_volume("SFX", value)

func _on_pinyin_slider_value_changed(value: float) -> void:
	AudioManager.set_bus_volume("Pinyin", value)

func _on_master_slider_value_changed(value: float) -> void:
	AudioManager.set_bus_volume("Master", value)
