extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const ROLL_SPEED = 200.0
const ROLL_DURATION = 0.4

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var is_rolling := false
var roll_timer := 0.0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get movement direction
	var direction := Input.get_axis("move_left", "move_right")
	
	# Handle roll with single Shift press
	if Input.is_action_just_pressed("shift") and is_on_floor() and not is_rolling:
		is_rolling = true
		roll_timer = ROLL_DURATION
		animated_sprite.play("roll")
	
	if is_rolling:
		roll_timer -= delta
		# Roll in the direction the sprite is facing
		if animated_sprite.flip_h:
			velocity.x = -ROLL_SPEED
		else:
			velocity.x = ROLL_SPEED
			
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
