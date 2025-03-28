extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const ROLL_SPEED = 200.0
const ROLL_DURATION = 0.4
const ROLL_CONTROL_MODIFIER = 0.5
const CAMERA_SPEED = 5.0
const LOOK_DOWN_DISTANCE = 50.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurt_sound: AudioStreamPlayer2D = $HurtSound
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
@onready var roll_sound: AudioStreamPlayer2D = $RollSound
@onready var camera: Camera2D = $Camera2D
@onready var weapon_scene = preload("res://weapon.tscn")

var is_rolling := false
var roll_timer := 0.0
var roll_direction := 1.0
var current_weapon = null
var has_fire_power = false
var can_shoot = true
var fire_cooldown = 0.5
var attack_timer = 0.0
var target_camera_offset = 0.0

func _physics_process(delta: float) -> void:
	# Add the gravity - use the built-in gravity directly
	if not is_on_floor():
		velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity", 980.0) * delta

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
		roll_sound.play()
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
				target_camera_offset = LOOK_DOWN_DISTANCE
			else:
				animated_sprite.play("idle")
				target_camera_offset = 0.0
			velocity.x = move_toward(velocity.x, 0, SPEED)
		
		if not is_on_floor():
			animated_sprite.play("jump")

	move_and_slide()

	# Handle cooldown timer
	if not can_shoot:
		attack_timer += delta
		if attack_timer >= fire_cooldown:
			can_shoot = true
			attack_timer = 0.0

	# Smooth camera movement
	camera.offset.y = lerp(camera.offset.y, target_camera_offset, delta * CAMERA_SPEED)

func play_hurt_animation():
	animated_sprite.play("hurt")
	if hurt_sound:
		hurt_sound.play()

func equip_weapon(weapon):
	if current_weapon:
		current_weapon.queue_free()
	current_weapon = weapon

func _unhandled_input(event):
	if event.is_action_pressed("attack") and current_weapon:
		if has_fire_power and can_shoot:
			# Shoot fire and start cooldown
			current_weapon.shoot_fire_projectile()
			can_shoot = false
			attack_timer = 0.0
		# Always do normal attack
		current_weapon.attack()

# Add is_player method here
func is_player() -> bool:
	return true

func _ready() -> void:
	var weapon = weapon_scene.instantiate()
	add_child(weapon)
	equip_weapon(weapon)

func enable_fire_power():
	has_fire_power = true
	print("Fire power enabled! Press E to shoot")  # Debug message
