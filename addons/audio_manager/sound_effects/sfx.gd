@tool
extends Node

var max_channels: int = 8
var channels = []

const RESOURCE_EXTENSION = ".tres"
const LIBRARY_PATH = "res://addons/audio_manager/resources/audios/"
var audios: Array[AudioData] = [] 
var config: AudioManagerConfig

func _ready():
	config = load("res://addons/audio_manager/config/config_resource.gd")
	audios = read_dir()

	for i in range(max_channels):
		var player = AudioStreamPlayer2D.new()
		add_child(player)
		channels.append(player)

func play(audio: AudioData):
	for player: AudioStreamPlayer2D in channels:
		if not player.playing:
			player.stream = audio.res_stream
			player.volume_db = audio.res_volume_db
			player.pitch_scale = audio.res_pitch_scale
			player.autoplay = true

			if audio.res_pitch_randomizer:
				var range = config.pitch_randomizer_range
				var rand := randf_range(-1 * range, range)
				player.pitch_scale += rand

			player.play()
			return

	# If all channels busy, play on first one (optional)
	# channels[0].stream = stream
	# channels[0].volume_db = volume_db
	# channels[0].pitch_scale = pitch_scale
	# channels[0].play()

func play_by_name(sound_name: String):
	for audio: AudioData in audios:
		if audio.res_name == sound_name:
			play(audio)

	push_error("Audio not found")
	return

func play_random(prefix: String) -> void:
	var matches := audios.filter(func(a): return a.res_name.begins_with(prefix))

	if matches.is_empty():
		push_warning("No sounds found with prefix: %s" % prefix)
		return
	var chosen: AudioData
	chosen = matches[randi() % matches.size()]
	play(chosen)

var play_index: Dictionary = {} # keeps track of last played index per prefix

func play_sequenctial(prefix: String) -> void:
	var matches := audios.filter(func(a): return a.res_name.begins_with(prefix))
	var idx := play_index.get(prefix, 0)
	var chosen: AudioData
	chosen = matches[idx]
	idx = (idx + 1) % matches.size()
	play_index[prefix] = idx

	play(chosen)

func read_dir() -> Array[AudioData]:
	audios = []
	var path = LIBRARY_PATH

	var dir = DirAccess.open(path)
	if dir == null:
		push_error("Audio Manager cannot open folder: %s" % path)
		return []

	dir.list_dir_begin()
	var filename = dir.get_next()

	while filename != "":
		# skip hidden files
		if filename.begins_with("."):
			filename = dir.get_next()
			continue

		elif filename.get_extension().to_lower() in RESOURCE_EXTENSION:
				var resource: AudioData = load(path + filename)
				assert(resource,"resource " + filename + " was not found")
				audios.append(resource)
		else: 
			push_error('The extension for this file is not supported: ', filename)

		filename = dir.get_next()

	dir.list_dir_end()

	return audios