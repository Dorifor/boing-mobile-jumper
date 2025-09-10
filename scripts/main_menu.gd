extends Control


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_cursed_mode_toggle_toggled(button_pressed: bool) -> void:
	PlayerPrefs.set_pref("cursed_mode", button_pressed)


func _on_settings_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/settings_menu.tscn")
