extends CharacterBody2D


@export var SPEED = 300.0
@export var JUMP_VELOCITY = -400.0
@export var GRAVITY_MULTIPLIER = 1

@export var animation_player: AnimationPlayer

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
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * GRAVITY_MULTIPLIER * delta
	
	# Handle Jump.
	if is_on_floor():
		var collided_platform = get_last_slide_collision().get_collider()
		if collided_platform != null:
			velocity.y = JUMP_VELOCITY
			var platform_animation: AnimationPlayer = collided_platform.get_node("Anim")
			animation_player.play("jump")
			platform_animation.play("breaking")
			just_jumped.emit(position.y)
			Input.vibrate_handheld(50)
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
