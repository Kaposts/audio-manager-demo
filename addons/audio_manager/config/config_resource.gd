@icon("res://addons/audio_manager/icon.svg")
extends Resource
class_name AudioManagerConfig

@export_group("SFX Settings")
# ## Pointer to listen for all sfx files and store them seperately in a GD script as consts
@export_dir var sfx_directory: String = "res://path/to/sound_effects/"
## Name for the output file that will handle sfx consts. This will also be the class_name which can be used to access these consts
@export var output_file_name: String = "audio"
## Pointer where to save generated Sound.gd which will store all consts for sounds
@export_dir var output_directory: String = "res://addons/audio_manager/resources/"
## const prefix for sound effects
@export var sound_effect_prefix: String = "SFX_"
# @export_range(-80, 6, 0.1, "Default volume for generated constants")
# var default_volume_db: float = 0.0


@export_group("Plugin Paths (IGNORE)")
@export var icon: Texture
@export var manager_ui: PackedScene
@export var sfx_script: String
@export var sfx_library_name: String