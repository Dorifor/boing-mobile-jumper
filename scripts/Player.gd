extends CharacterBody2D


@export var SPEED = 300.0
@export var JUMP_VELOCITY = -400.0
@export var GRAVITY_MULTIPLIER = 1

@export var animation_player: AnimationPlayer
@export var jump_sounds: Array[AudioStream] = []
@export var jump_audio_player: AudioStreamPlayer

signal just_jumped(player_y_position: int)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var screen_width: int = ProjectSettings.get_setting("display/window/size/viewport_width")
var screen_height: int = ProjectSettings.get_setting("display/window/size/viewport_height")


func _physics_process(delta: float) -> void:
	if position.x > screen_width:
		position.x = 0
	if position.x < 0:
		position.x = screen_width
	
	if not is_on_floor():
		velocity.y += gravity * GRAVITY_MULTIPLIER * delta
	
	if is_on_floor():
		jump()
	
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


func jump():
	var collided_platform = get_last_slide_collision().get_collider()
	if collided_platform != null:
		velocity.y = JUMP_VELOCITY
		break_platform(collided_platform)
		play_random_jump_sound()
		Input.vibrate_handheld(25)
		just_jumped.emit(position.y)


func break_platform(platform):
	var platform_animation_player: AnimationPlayer = platform.get_node("Anim")
	var jump_animation = get_random_jump_animation()
	animation_player.play(jump_animation)
	platform_animation_player.play("breaking")


func play_random_jump_sound() -> void:
	var rand = randi_range(0, len(jump_sounds) - 1)
	var random_sound = jump_sounds[rand]
	jump_audio_player.stream = random_sound
	jump_audio_player.play()

func get_random_jump_animation() -> String:
	var rand = randi_range(0, 10)
	match rand:
		1:
			return "jump_spin_left"
		2: 
			return "jump_spin_right"
		_:
			return "jump"
