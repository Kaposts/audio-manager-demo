@tool
extends EditorPlugin
class_name AudioManager

const audio_extensions: Array[String] = ["wav", "ogg"]

var icon: Texture
var button: Button

var sounds: Array[SFXData] = []
var library: SFXLibrary = SFXLibrary.new()
var sound_script_lines: Array[String] = []

var config: AudioManagerConfig = preload("res://addons/audio_manager/config/config.tres")
var output_directory: String = "res://addons/audio_manager/resources/"
var output_file_name: String = "audio"
var sound_effect_prefix: String = "SFX_"

var window_instance: SFXManagerWindow

func _init() -> void:
    assert(config,"Config not found")
    icon = config.icon

func _enter_tree() -> void:
    _init()

    ## Create a button in the toolbar
    button = Button.new()
    button.icon = icon
    button.tooltip_text = "Open Audio Manager"
    button.pressed.connect(_on_button_pressed)
    add_control_to_container(CONTAINER_TOOLBAR, button)
    button.show()
    button.add_theme_constant_override("icon_max_width", 32)

    add_autoload_singleton("SFX", config.sfx_script)
    print("SFX Generator plugin loaded")

func _exit_tree() -> void:
    # Remove button when plugin is disabled
    remove_control_from_container(CONTAINER_TOOLBAR, button)
    button.free()
    remove_autoload_singleton("SFX")

func _on_button_pressed() -> void:
    if not window_instance:
        window_instance = config.manager_ui.instantiate()
        add_child(window_instance)  # add to editor tree
        # connect regen button here if not handled in the scene script
        # window_instance.regen_button.pressed.connect(_on_regen_pressed)
        window_instance.loadBut.pressed.connect(_on_load_pressed)
        window_instance.load_library()
        window_instance.popup_centered()

func _on_load_pressed() -> void:
    assert(config.sfx_directory != "","sfx_directory can't be empty")
    assert(config.output_directory != "","output_directory can't be empty")
    assert(config.output_file_name != "","output_file_name can't be empty")

    output_directory = config.output_directory
    output_file_name = config.output_file_name
    sound_effect_prefix = config.sound_effect_prefix
    
    ## TODO could make this to copy a file 
    sound_script_lines = ["## Made using Audio Manager\n","## This is a auto generated file to store audio consts\n","extends Node\n","class_name ", output_file_name.to_pascal_case(),"\n", ]
    
    read_sfx_files()
    generate_library()
    write_const_file()

func create_sfx_data(sfx: AudioStream, prefix: String) -> SFXData:
    assert(sfx, "no sfx defined")

    var sfx_name = get_base_name(sfx)
    assert(sfx_name != "", "sfx_name is empty")
    
    var const_name = sound_effect_prefix
    if prefix != "":
        const_name += prefix + "_"
    const_name += sfx_name

    var data = SFXData.new()
    data.res_name = const_name.to_lower()
    data.res_stream = sfx

    sound_script_lines.append("const %s = \"%s\"\n" % [to_upper_snake_case(const_name), const_name.to_lower()])

    library.sounds.append(data)

    print('Audio sfx data .tres status : ',ResourceSaver.save(data, output_directory + "audios/" + data.res_name + '.tres'))

    print("Initialized: " + sfx_name, " as const: " + const_name)

    return data

func write_const_file() -> void:
    var output_path = output_directory + output_file_name + ".gd"
    var file = FileAccess.open(output_path, FileAccess.WRITE)
    if file:
        var str = ""
        file.store_string(str.join(sound_script_lines))
        file.close()
        print("Sounds.gd generated in ", output_path)

    else:
        push_error("Failed to write file: ", output_path)

func read_sfx_files() -> void:
    var path = config.sfx_directory
    print("Scanning: ", path)

    var dir = DirAccess.open(path)
    if dir == null:
        push_error("Cannot open folder: %s" % path)
        return

    _scan_dir_recursive(dir, "", path)

func generate_library() -> void:
    var save_path = output_directory + config.sfx_library_name
    ResourceSaver.save(library, save_path)

func get_base_name(resource) -> String:
    return resource.resource_path.get_file().get_basename()

func _scan_dir_recursive(dir: DirAccess, prefix: String, base_path: String):
    dir.list_dir_begin()
    var filename = dir.get_next()

    while filename != "":
        if filename.begins_with("."): # skip hidden files
            filename = dir.get_next()
            continue

        var full_path = dir.get_current_dir().path_join(filename)

        if dir.current_is_dir():
            # Recurse into subfolder, add folder name as prefix
            var new_prefix = prefix
            if new_prefix != "":
                new_prefix += "_"
            new_prefix += filename.to_upper()
            var subdir = DirAccess.open(full_path)
            if subdir:
                _scan_dir_recursive(subdir, new_prefix, base_path)
        else:
            if filename.get_extension().to_lower() in audio_extensions:
                var stream = load(full_path)
                create_sfx_data(stream, prefix)

        filename = dir.get_next()

    dir.list_dir_end()

func to_upper_snake_case(str: String) -> String:
    str.to_upper()
    str.replace(" ", "_")
    str.replace("-", "_")
    return str