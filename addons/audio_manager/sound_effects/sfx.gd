extends Node

@export var max_channels: int = 8

var channels = []
var sfx_library: Dictionary = {}

func _ready():
	var lib: SFXLibrary = load("res://addons/audio_manager/resources/SFXLibrary.tres")
	for sound: AudioData in lib.sounds:
		sfx_library[sound.res_name] = sound

	for i in range(max_channels):
		var player = AudioStreamPlayer2D.new()
		add_child(player)
		channels.append(player)

func play_sfx(sound_name: String, volume_db: float = 0, pitch_scale: float = 1.0):
	var stream: AudioData = sfx_library.get(sound_name)

	if stream:
		for player: AudioStreamPlayer2D in channels:
			if not player.playing:
				player.stream = stream.res_stream
				player.volume_db = volume_db
				player.pitch_scale = pitch_scale
				player.autoplay = true
				player.play()
				return

		# If all channels busy, play on first one (optional)
		# channels[0].stream = stream
		# channels[0].volume_db = volume_db
		# channels[0].pitch_scale = pitch_scale
		# channels[0].play()
