@tool
extends Window
class_name SFXManagerWindow

var audios: Array[AudioData] = [] 
var results: Array[AudioData] = [] 

@onready var library_label: Label = $SFX/Label
@onready var audios_controls = $SFX/Audios/v_box

const RESOURCE_EXTENSION = ".tres"
const LIBRARY_PATH = "res://addons/audio_manager/resources/audios/"

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
                var resource: AudioData = load(LIBRARY_PATH + filename)
                assert(resource,"resource " + filename + " was not found")
                audios.append(resource)
        else: 
            push_error('The extension for this file is not supported: ', filename)

        filename = dir.get_next()
    
    dir.list_dir_end()

    results = audios



func _on_config_pressed() -> void:
    hide_tabs()
    $Config.show()

func _on_bgm_pressed() -> void:
    hide_tabs()
    $BGM.show()

func _on_sfx_pressed() -> void:
    hide_tabs()
    $SFX.show()

func hide_tabs():
    $Welcome.hide()
    $SFX.hide()
    $Config.hide()
    $BGM.hide()


## STUFF FOR CONTROLING SOUNF EFFECTS
## TODO maybe move it inside sfx_control.gd

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
    var ui = $SFX/Audios/v_box
    for child in ui.get_children():
        child.queue_free()

func _on_search_text_changed() -> void:
    var query: String = $SFX/search.text.strip_edges().to_lower()
    results = []

    for audio in audios:
        if query == "" or audio.res_name.to_lower().find(query) != -1:
            results.append(audio)
    clear_audios()
    load_audios()
