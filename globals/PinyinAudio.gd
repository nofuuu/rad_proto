extends Node
class_name AudioPlayer

const AUDIO_FOLDER_PATH = "res://audio/audio-cmn-master/syllabs/"
var audio_player: AudioStreamPlayer

const TONE_MAP = {
	"ā": ["a", "1"], "á": ["a", "2"], "ǎ": ["a", "3"], "à": ["a", "4"],
	"ē": ["e", "1"], "é": ["e", "2"], "ě": ["e", "3"], "è": ["e", "4"],
	"ī": ["i", "1"], "í": ["i", "2"], "ǐ": ["i", "3"], "ì": ["i", "4"],
	"ō": ["o", "1"], "ó": ["o", "2"], "ǒ": ["o", "3"], "ò": ["o", "4"],
	"ū": ["u", "1"], "ú": ["u", "2"], "ǔ": ["u", "3"], "ù": ["u", "4"],
	"ǖ": ["v", "1"], "ǘ": ["v", "2"], "ǚ": ["v", "3"], "ǜ": ["v", "4"]
}

func _ready() -> void:
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	
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
	var file_path = AUDIO_FOLDER_PATH + "cmn-" + cleaned_pinyin + ".mp3"
	if ResourceLoader.exists(file_path):
		var stream = load(file_path)
		audio_player.stream = stream
		audio_player.play()
	else:
		push_error("Pinyin audio file not found at: " + file_path)
