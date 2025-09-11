@tool
extends Window
class_name SFXManagerWindow

var audios: Array[SFXData] = [] 
var results: Array[SFXData] = [] 

@onready var library_label: Label = $Label
@onready var audios_controls = $Audios/v_box

const RESOURCE_EXTENSION = ".tres"
const LIBRARY_PATH = "res://addons/audio_manager/resources/audios/"

## legacy
const LIBRARY_FILE_PATH = "res://addons/audio_manager/resources/sfx_library.tres"

@onready var loadBut: Button = $VBoxContainer/Load

func load_library():
    read_dir()
    load_audios()

func _on_close_pressed() -> void:
    queue_free()

func read_dir() -> void:
    var path = LIBRARY_PATH

    var dir = DirAccess.open(path)
    if dir == null:
        push_error("Audio Manager cannot open folder: %s" % path)
        return

    dir.list_dir_begin()
    var filename = dir.get_next()

    while filename != "":
        # skip hidden files
        if filename.begins_with("."):
            filename = dir.get_next()
            continue

        elif filename.get_extension().to_lower() in RESOURCE_EXTENSION:
                var resource: SFXData = load(LIBRARY_PATH + filename)
                assert(resource,"resource " + filename + " was not found")
                audios.append(resource)
        else: 
            push_error('The extension for this file is not supported: ', filename)

        filename = dir.get_next()
    
    dir.list_dir_end()

    results = audios

func load_audios():
    library_label.text = "Audios: " + str(results.size())
    for audio in results:
        var control: SFXControl = load("res://addons/audio_manager/ui/sfx_control.tscn").instantiate()

        control.set_name_label(audio.res_name)
        control.set_volume_slider(audio.res_volume_db)
        control.set_pitch_slider(audio.res_pitch_scale)
        control.set_resource(audio)

        audios_controls.add_child(control)

func clear_audios():
    var ui = $Audios/v_box
    for child in ui.get_children():
        child.queue_free()

##legacy
func legacy_load():
    if ResourceLoader.exists(LIBRARY_FILE_PATH):
        var lib: SFXLibrary = load(LIBRARY_FILE_PATH)

        var lines = []
        for sound: SFXData in lib.sounds:
            lines.append(sound.res_name)

        if lib and lib.has_method("get"):
            library_label.text = "Loaded library: %s (sounds: %d)" % [LIBRARY_FILE_PATH, lib.sounds.size()]
            for sound: SFXData in lib.sounds:
                # library_label.text += str("\n",line)
                var control: SFXControl = load("res://addons/audio_manager/ui/sfx_control.tscn").instantiate()
                control.set_name_label(sound.res_name)
                control.set_volume_slider(sound.res_volume_db)
                control.set_pitch_slider(sound.res_pitch_scale)
                control.set_resource(sound)
                # control.name_label.text = line
                audios_controls.add_child(control)
        else:
            library_label.text = "⚠️ Invalid SFXLibrary file"
    else:
        library_label.text = "❌ No library found"

func _on_search_text_changed() -> void:

    var query: String = $search.text.strip_edges().to_lower()
    results = []

    for audio in audios:
        if query == "" or audio.res_name.to_lower().find(query) != -1:
            results.append(audio)
    clear_audios()
    load_audios()