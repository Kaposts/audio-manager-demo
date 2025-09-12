extends Node2D

func _on_play_by_name_pressed() -> void:
	SFX.play_by_name(Audio.SFX_CLICK_001)


func _on_play_random_pressed() -> void:
	SFX.play_random('sfx_click')


func _on_play_sequence_pressed() -> void:
	SFX.play_sequenctial('sfx_click')
