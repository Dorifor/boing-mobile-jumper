extends Node2D

@export var platform_scenes: Array[PackedScene] = []
@export var score_label: Label
@export var death_container: Control
@export var death_area: Area2D
@export var highscore_label: Label

var highscore = 0
var previous_x_position = 0

var screen_width: int = ProjectSettings.get_setting("display/window/size/viewport_width")
var screen_height: int = ProjectSettings.get_setting("display/window/size/viewport_height")

func _ready() -> void:
	highscore = PlayerPrefs.get_pref("highscore", 0)


func _on_player_just_jumped(player_y_position) -> void:
	spawn_new_platform(player_y_position)
	death_area.position.y = player_y_position + screen_height / 2
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


func spawn_new_platform(player_y_position) -> void:
	var new_platform = get_random_platform().instantiate()
	new_platform.position.x = get_new_platform_x_position(50)
	new_platform.position.y = player_y_position - screen_height
	new_platform.scale.x = randf_range(.8, 1.5)
	add_child(new_platform)


func get_new_platform_x_position(iterations: int) -> int:
	var new_x_position = randi_range(150, screen_width - 150)
	
	if iterations == 0:
		return new_x_position
	
	var offset = 550 if iterations >= 15 else 350
	if previous_x_position - offset <= new_x_position and new_x_position >= previous_x_position + offset:
		previous_x_position = new_x_position
		return new_x_position
	return get_new_platform_x_position(iterations - 1)


func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()


func get_random_platform() -> PackedScene:
	var i = randi_range(0, len(platform_scenes) - 1)
	return platform_scenes[i]
