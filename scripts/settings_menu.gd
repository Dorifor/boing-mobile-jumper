extends Control

@export var vibration_checkbox: CheckBox
@export var cursed_sounds_checkbox: CheckBox

func _ready() -> void:
	var is_cursed_mode_toggled = PlayerPrefs.get_pref("cursed_mode", false)
	var are_vibrations_toggled = PlayerPrefs.get_pref("vibrations", true)
	vibration_checkbox.set_pressed_no_signal(are_vibrations_toggled)
	cursed_sounds_checkbox.set_pressed_no_signal(is_cursed_mode_toggled)


func _on_vibrations_check_box_toggled(toggled_on: bool) -> void:
	PlayerPrefs.set_pref("vibrations", toggled_on)


func _on_cursed_check_box_toggled(toggled_on: bool) -> void:
	PlayerPrefs.set_pref("cursed_mode", toggled_on)


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
