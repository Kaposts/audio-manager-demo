@tool
extends Control
class_name ConfigControl

var config: AudioManagerConfig = preload("res://addons/audio_manager/config/config.tres")

func _ready():
	$config_container/sfx_directory/btn.pressed.connect(_on_browse_pressed)
	$config_container/sfx_directory/FileDialog.dir_selected.connect(_on_dir_selected)
	$config_container/sfx_directory/input.text = config.sfx_directory

func _on_dir_selected(dir: String):
	config.sfx_directory = dir
	$config_container/sfx_directory/input.text = config.sfx_directory
	save()

func _on_browse_pressed() -> void:
	$config_container/sfx_directory/FileDialog.show()

func save():
	ResourceSaver.save(config, config.resource_path)
