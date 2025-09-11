@tool
extends Control
class_name ConfigControl

const CONFIG_PATH = "res://addons/audio_manager/config/config.tres"
var config: AudioManagerConfig

func _ready() -> void:
	config = load(CONFIG_PATH)
	_init()

	$config_container/sfx_directory/btn.pressed.connect(_on_browse_pressed)
	$config_container/sfx_directory/FileDialog.dir_selected.connect(_on_dir_selected)

func _init():
	$config_container/sfx_directory/input.text = config.sfx_directory
	$config_container/sfx_directory/btn

func _on_dir_selected(dir: String):
	print(dir)
	config.sfx_directory = dir
	$config_container/sfx_directory/input.text = config.sfx_directory
	save()

func _on_browse_pressed() -> void:
	$config_container/sfx_directory/FileDialog.show()

func save():
	ResourceSaver.save(config, config.resource_path)
