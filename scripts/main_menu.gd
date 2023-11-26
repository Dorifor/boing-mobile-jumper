extends Control

@export var game_scene: PackedScene
@export var cursed_mode_toggle: CheckButton

func _ready() -> void:
	var is_cursed_mode_toggled = PlayerPrefs.get_pref("cursed_mode", false)
	cursed_mode_toggle.set_pressed_no_signal(is_cursed_mode_toggled)


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_packed(game_scene)


func _on_cursed_mode_toggle_toggled(button_pressed: bool) -> void:
	PlayerPrefs.set_pref("cursed_mode", button_pressed)
