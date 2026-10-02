extends Node
class_name AudioPlayer

const PINYIN_BUS = "Pinyin"
const MUSIC_BUS = "Music"
const UI_BUS = "UI"
const SFX_BUS = "SFX"

const PINYIN_FOLDER_PATH = "res://audio/audio-cmn-master/syllabs/"
const UI_FOLDER = "res://audio/UI/"
const SFX_FOLDER = "res://audio/SFX/"
const BACKGROUND_MUSIC = "res://audio/Ripples.mp3"

const TONE_MAP = {
	"ā": ["a", "1"], "á": ["a", "2"], "ǎ": ["a", "3"], "à": ["a", "4"],
	"ē": ["e", "1"], "é": ["e", "2"], "ě": ["e", "3"], "è": ["e", "4"],
	"ī": ["i", "1"], "í": ["i", "2"], "ǐ": ["i", "3"], "ì": ["i", "4"],
	"ō": ["o", "1"], "ó": ["o", "2"], "ǒ": ["o", "3"], "ò": ["o", "4"],
	"ū": ["u", "1"], "ú": ["u", "2"], "ǔ": ["u", "3"], "ù": ["u", "4"],
	"ǖ": ["v", "1"], "ǘ": ["v", "2"], "ǚ": ["v", "3"], "ǜ": ["v", "4"]
}

var pinyin_player: AudioStreamPlayer
var music_player: AudioStreamPlayer
# Independent players allow short sounds to overlap
var sfx_players: Array[AudioStreamPlayer] = []
var ui_players: Array[AudioStreamPlayer] = []
const PLAYER_POOL_SIZE: int = 8

const MIN_VOLUME_DB: float = -40.0

func _ready() -> void:
	music_player = _create_player(MUSIC_BUS)
	pinyin_player = _create_player(PINYIN_BUS)
	for i in range(PLAYER_POOL_SIZE):
		sfx_players.append(_create_player(SFX_BUS))
		ui_players.append(_create_player(UI_BUS))
	play_music()
	set_bus_volume("Music", -25.0)
	set_bus_volume("UI", -25.0)
	set_bus_volume("SFX", -15.0)
		
func _create_player(bus_name: String) -> AudioStreamPlayer:
	var player = AudioStreamPlayer.new()
	player.bus = bus_name
	add_child(player)
	return player
	
# ==============================================================================
# VOLUME MANAGEMENT
# ==============================================================================
func set_bus_volume(bus_name: StringName, value_db: float) -> void:
	var index := AudioServer.get_bus_index(bus_name)
	if index < 0:
		push_warning("Audio bus not found: " + String(bus_name))
		return
	if value_db <= MIN_VOLUME_DB:
		AudioServer.set_bus_mute(index, true)
	else:
		AudioServer.set_bus_mute(index, false)
		AudioServer.set_bus_volume_db(index, value_db)

func get_bus_volume(bus_name: StringName) -> float:
	var index := AudioServer.get_bus_index(bus_name)
	if index < 0:
		return MIN_VOLUME_DB
	if AudioServer.is_bus_mute(index):
		return MIN_VOLUME_DB
	return AudioServer.get_bus_volume_db(index)
	

# ==============================================================================
# PINYIN PRONUNCIATION
# ==============================================================================
func clean_pinyin(input: String) -> String:
	if input.is_empty():
		return ""
	# If ends with number, assume correct format
	if input[-1].is_valid_int():
		return input
		
	var clean_str = ""
	var tone = "5" # Default 5 neutral tone if no tone mark is found
	
	for i in range(input.length()):
		var c = input[i]
		if TONE_MAP.has(c):
			clean_str += TONE_MAP[c][0] # Add the clean vowel
			tone = TONE_MAP[c][1]       # Save the tone number
		else:
			clean_str += c  # Keep consonants and unaccented vowels
	return clean_str + tone

func play_pinyin(pinyin: String) -> void :
	var cleaned_pinyin = clean_pinyin(pinyin)
	var file_path = PINYIN_FOLDER_PATH + "cmn-" + cleaned_pinyin + ".mp3"
	if ResourceLoader.exists(file_path):
		var stream = load(file_path)
		pinyin_player.stream = stream
		pinyin_player.play()
	else:
		push_error("Pinyin audio file not found at: " + file_path)


# ==============================================================================
# BACKGROUND MUSIC
# ==============================================================================
func play_music() -> void:
	if not ResourceLoader.exists(BACKGROUND_MUSIC):
		push_error("Music file not found: " + BACKGROUND_MUSIC)
		return
	var stream := load(BACKGROUND_MUSIC) as AudioStream
	if stream == null:
		push_error("Invalid music audio file: " + BACKGROUND_MUSIC)
		return
	if music_player.stream == stream and music_player.playing:
		return
	music_player.stop()
	music_player.stream = stream
	music_player.play()

# ==============================================================================
# SFX
# ==============================================================================
func play_sfx(file_name: String) -> void:
	_play_from_pool(
		SFX_FOLDER + file_name,
		sfx_players
	)

func play_ui(file_name: String) -> void:
	_play_from_pool(
		UI_FOLDER + file_name,
		ui_players
	)

# ==============================================================================
# RECYCLING SOUND POOL
# ==============================================================================
func _play_from_pool(
	path: String,
	pool: Array[AudioStreamPlayer]
) -> void:
	if not ResourceLoader.exists(path):
		push_error("Audio file not found: " + path)
		return

	var stream := load(path) as AudioStream
	if stream == null:
		push_error("Invalid audio file: " + path)
		return

	for player in pool:
		if not player.playing:
			player.stream = stream
			player.play()
			return

	# All voices are busy: reuse the first one.
	pool[0].stream = stream
	pool[0].play()
