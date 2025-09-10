extends Node2D

# base width : 80px (3 parts: 240px) (then 2x scale: 480px)
const BASE_PLATFORM_WIDTH: int = 480
const BACKGROUND_HEIGHT: int = 4736

@export var platform_scenes: Array[PackedScene] = []
@export var death_sounds: Array[AudioStream]
@export var death_sounds_cursed: Array[AudioStream]
@export var platform_distance: int = 850

@export var score_label: Label
@export var death_container: Control
@export var death_area: Area2D
@export var highscore_label: Label
@export var sound_player: AudioStreamPlayer
@export var right_arrow: TextureRect
@export var left_arrow: TextureRect

var highscore = 0
var prev_x_position = 0
@export var platforms: Array[AnimatableBody2D]
@export var backgrounds: Array[Sprite2D]

var screen_width: int = ProjectSettings.get_setting("display/window/size/viewport_width")
var screen_height: int = ProjectSettings.get_setting("display/window/size/viewport_height")

func _ready() -> void:
	highscore = PlayerPrefs.get_pref("highscore", 0)

func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("ui_accept"):
		get_tree().reload_current_scene()


func _on_player_just_jumped(platform_position: Vector2) -> void:
	spawn_new_platform(platform_position)
	death_area.position.y = platform_position.y + platform_distance
	update_score_label()


func update_score_label() -> void:
	var tween = get_tree().create_tween()
	score_label.text = str(int(score_label.text) + 1)
	tween.tween_property(score_label, "scale", Vector2(1.2, 1.2), .1)
	tween.tween_property(score_label, "scale", Vector2(1, 1), .1)


func _on_death_body_entered(body: Node2D) -> void:
	body.queue_free()
	var score = int(score_label.text)
	highscore = max(score, highscore)
	highscore_label.text = str(highscore)
	PlayerPrefs.set_pref("highscore", highscore)
	death_container.show()
	play_random_death_sound()


func play_random_death_sound() -> void:
	var is_cursed_mode = PlayerPrefs.get_pref("cursed_mode", false)
	var death_sounds_list = death_sounds_cursed if is_cursed_mode else death_sounds
	var rand = randi_range(0, len(death_sounds_list) - 1)
	var random_sound = death_sounds_list[rand]
	sound_player.stream = random_sound
	sound_player.play()


func spawn_new_platform(prev_platform_position: Vector2) -> void:
	var new_platform: AnimatableBody2D = get_random_platform().instantiate()
	var new_scale = randf_range(.8, 1.5)
	new_platform.position.y = prev_platform_position.y - 3 * platform_distance
	new_platform.position.x = get_new_platform_x_position(new_scale)
	new_platform.scale.x = new_scale
	
	add_child(new_platform)
	platforms.append(new_platform)


func get_new_platform_x_position(new_platform_x_scale: float) -> int:
	# new_platform_width / 2 -> prev_x - prev_w / 2 || prev_x + prev_w / 2 -> screen_width - new_platform_width / 2
	var left = randi_range(0, 1) == 1
	var total_random = randi_range(0, 10) > 6
	
	var prev_platform = platforms.get(platforms.size() - 1)
	
	var prev_platform_width = prev_platform.scale.x * BASE_PLATFORM_WIDTH
	var new_platform_width = new_platform_x_scale * BASE_PLATFORM_WIDTH
	
	var left_min = new_platform_width / 2
	var left_max = prev_platform.position.x - prev_platform_width / 1.75
	
	var right_min = prev_platform.position.x + prev_platform_width / 1.75
	var right_max = screen_width - new_platform_width / 2
	
	if total_random:
		return randi_range(left_min, right_max)
	
	if left_max <= left_min:
		left = false
	if right_max <= right_min:
		left = true
	
	return randi_range(left_min, left_max) if left else randi_range(right_min, right_max)

func on_background_area_reached(body: Node2D):
	var last_bg: Sprite2D = backgrounds.pop_at(0)
	var current: Sprite2D = backgrounds[0]
	current.get_child(0).set_deferred("monitoring", false)
	current.get_child(0).get_child(0).set_deferred("disabled", true)
	last_bg.get_child(0).set_deferred("monitoring", true)
	last_bg.get_child(0).get_child(0).set_deferred("disabled", false)
	last_bg.position.y -= BACKGROUND_HEIGHT * 3
	backgrounds.append(last_bg)

func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()


func get_random_platform() -> PackedScene:
	var i = randi_range(0, len(platform_scenes) - 1)
	return platform_scenes[i]


func _on_left_button_pressed() -> void:
	left_arrow.modulate = Color("#376fa49b")


func _on_left_button_released() -> void:
	left_arrow.modulate = Color("#ffffff9b")


func _on_right_button_pressed() -> void:
	right_arrow.modulate = Color("#376fa49b")


func _on_right_button_released() -> void:
	right_arrow.modulate = Color("#ffffff9b")


func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
