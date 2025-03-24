extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const ROLL_SPEED = 200.0
const ROLL_DURATION = 0.4
const ROLL_CONTROL_MODIFIER = 0.5  # How much control player has during roll

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurt_sound: AudioStreamPlayer2D = $HurtSound
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
var is_rolling := false
var roll_timer := 0.0
var roll_direction := 1.0  # Store roll direction

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get movement direction
	var direction := Input.get_axis("move_left", "move_right")
	
	# Handle jump (now with sound)
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump_sound.play()

	# Handle roll with single Shift press - can now roll anytime
	if Input.is_action_just_pressed("shift") and not is_rolling:
		is_rolling = true
		roll_timer = ROLL_DURATION
		# Store the direction at roll start, use movement direction if available
		if direction != 0:
			roll_direction = sign(direction)
		else:
			roll_direction = -1.0 if animated_sprite.flip_h else 1.0
		animated_sprite.play("roll")
	
	if is_rolling:
		roll_timer -= delta
		# Base roll velocity
		var roll_velocity = ROLL_SPEED * roll_direction
		
		# Allow some control during roll
		if direction != 0:
			roll_velocity += direction * SPEED * ROLL_CONTROL_MODIFIER
		
		velocity.x = roll_velocity
			
		if roll_timer <= 0:
			is_rolling = false
	else:
		# Normal movement
		if direction > 0:
			animated_sprite.flip_h = false
			animated_sprite.play("run")
			velocity.x = SPEED
		elif direction < 0:
			animated_sprite.flip_h = true
			animated_sprite.play("run")
			velocity.x = -SPEED
		else:
			animated_sprite.play("idle")
			velocity.x = move_toward(velocity.x, 0, SPEED)
		
		if not is_on_floor():
			animated_sprite.play("jump")

	move_and_slide()

func play_hurt_animation():
	animated_sprite.play("hurt")
	if hurt_sound:
		hurt_sound.play()
