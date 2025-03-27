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
var current_weapon = null
var has_fire_power = false
var can_shoot = true
var fire_cooldown = 0.5
var fire_scene = preload("res://fireprojectile.tscn")

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
			# Check for move_down input
			if Input.is_action_pressed("move_down"):
				animated_sprite.play("chillin")
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

func equip_weapon(weapon):
	if current_weapon:
		current_weapon.queue_free()
	current_weapon = weapon

func _unhandled_input(event):
	# Normal weapon attack
	if event.is_action_pressed("attack") and current_weapon:
		current_weapon.attack()
	# Fire power attack (E key)
	elif event.is_action_pressed("shoot_fire") and has_fire_power and current_weapon:
		current_weapon.shoot_fire_projectile()  # Use the weapon's shoot function instead

# Add this helper method
func is_player() -> bool:
	return true

func _ready():
	# Test code - remove after testing
	var weapon = load("res://weapon.tscn").instantiate()
	add_child(weapon)
	equip_weapon(weapon)

func enable_fire_power():
	has_fire_power = true
	print("Fire power enabled!")
