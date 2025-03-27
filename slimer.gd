extends Node2D  # Change back to Node2D since that's what worked before

const SLIMESPEED = 60
const GRAVITY = 980
const JUMP_FORCE = -300
const JUMP_INTERVAL = 4.0  # Increased from 2.0 to 4.0 seconds between jumps
const KILL_DISTANCE = 50  # How close you need to be to kill the slime
const CHECK_INTERVAL = 0.1  # Check ground every 0.1 seconds
const SAFE_JUMP_DISTANCE = 200  # Maximum safe jumping distance

var direction = 1 
var game_manager: Node
var is_dying = false
var velocity = Vector2.ZERO
var jump_timer = 0.0
var check_timer = 0.0

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ground_check: RayCast2D = $GroundCheck  # Reference the new ground check
var jump_check: RayCast2D  # Remove @onready since we create it dynamically
var player_in_range = false
var current_player = null
@onready var death_sound = $DeathSound  # Add this line

func _process(delta: float) -> void:
	if is_dying:
		return
		
	# Apply gravity
	velocity.y += GRAVITY * delta
	
	# Check if on ground using ground check raycast
	if ground_check.is_colliding():
		velocity.y = 0
		# Handle jumping
		jump_timer += delta
		if jump_timer >= JUMP_INTERVAL:
			# Only jump if it's safe
			if is_safe_to_jump():
				velocity.y = JUMP_FORCE
				jump_timer = 0
			else:
				# If not safe to jump, turn around instead
				direction *= -1
				animated_sprite.flip_h = !animated_sprite.flip_h
				jump_timer = JUMP_INTERVAL * 0.5  # Reset timer partially to check again soon
			
		# Edge detection - check if about to walk off platform
		# Move ground check ahead of movement direction to look for edges
		var original_pos = ground_check.position
		ground_check.position.x = direction * 15  # Look further ahead (increased from 10 to 15)
		ground_check.force_raycast_update()  # Force immediate update
		
		# If there's no ground ahead, turn around
		if not ground_check.is_colliding():
			direction *= -1
			animated_sprite.flip_h = !animated_sprite.flip_h
		
		# Reset ground check position
		ground_check.position = original_pos
		ground_check.force_raycast_update()  # Force update after resetting
	
	# Normal wall collision checks
	if ray_cast_right.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
	if ray_cast_left.is_colliding():
		direction = 1
		animated_sprite.flip_h = false
	
	velocity.x = direction * SLIMESPEED
	
	# Apply movement
	position += velocity * delta

func _ready():
	game_manager = get_node_or_null("/root/Game/GameManager")
	add_to_group("slimes")
	
	# Set up raycasts
	ray_cast_right.enabled = true
	ray_cast_left.enabled = true
	ground_check.enabled = true
	ground_check.collision_mask = 1
	
	# Set up jump check raycast
	jump_check = RayCast2D.new()
	add_child(jump_check)
	jump_check.enabled = true
	jump_check.collision_mask = 1  # Same collision mask as ground check
	jump_check.position = Vector2(0, 6)  # Same height as ground check
	
	# Debug initial setup
	print("Ground check setup - Position: ", ground_check.position)
	print("Ground check collision mask: ", ground_check.collision_mask)
	print("Ground check target position: ", ground_check.target_position)

func take_damage():
	if is_dying:  # Prevent multiple deaths
		return
	
	is_dying = true
	print("Slime taking damage! Current slime count before adding: ", game_manager.slimes_killed if game_manager else "no manager")
	
	# Add slime kill count before death animation
	if game_manager:
		game_manager.add_slime_kill()
	
	# Prevent multiple calls to take_damage
	set_process(false)  # Disable processing
	set_physics_process(false)  # Disable physics processing
	
	# Remove all collisions to prevent further triggers
	if has_node("Hitbox"):
		$Hitbox.set_deferred("monitoring", false)
		$Hitbox.set_deferred("monitorable", false)
	
	# Play death sound
	if death_sound:
		death_sound.play()
	
	# Play death animation
	animated_sprite.play("slimedeath")
	
	# Create one smooth falling sequence
	var tween = create_tween()
	# Smooth arc motion - up then down
	tween.tween_property(self, "position", position + Vector2(0, -80), 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", position + Vector2(50, 1000), 1.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	# Gentle spin while falling
	tween.parallel().tween_property(self, "rotation", 3.14, 1.6).set_trans(Tween.TRANS_QUAD)
	# Fade out near the end
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.6).set_delay(1.0)
	
	# Wait for both sound and animation
	await tween.finished
	queue_free()

func _on_hitbox_body_entered(body):
	if body.has_method("is_player"):
		var player = body as CharacterBody2D
		
		# If player is falling down, kill slimer
		if player.velocity.y > 0:
			take_damage()
		# If player hits from side, hurt player
		elif not is_dying:  # Only hurt player if slimer isn't already dying
			if body.has_method("play_hurt_animation"):
				body.play_hurt_animation()
				print("You Died")
				Engine.time_scale = 0.5
				body.get_node("CollisionShape2D").queue_free()
				await get_tree().create_timer(0.6).timeout
				Engine.time_scale = 1
				get_tree().change_scene_to_file("res://scenes/game_over.tscn")

func _on_hitbox_body_exited(body):
	if body.has_method("is_player"):
		player_in_range = false
		current_player = null

func _on_hitbox_area_entered(area):
	print("Area entered: ", area.name)  # Debug print
	if area.is_in_group("fireballs"):
		print("Fireball hit slime!")  # Debug print
		take_damage()
		area.queue_free()  # Remove the fireball after it hits

func is_safe_to_jump() -> bool:
	# Calculate approximate landing position based on physics
	var jump_time = (-2 * JUMP_FORCE) / GRAVITY  # Time to reach peak
	var total_time = jump_time * 2  # Approximate time for full jump
	var jump_distance = SLIMESPEED * direction * total_time
	
	# Set raycast to check landing position
	jump_check.target_position = Vector2(jump_distance, 200)  # Check downward at landing position
	jump_check.force_raycast_update()
	
	# If we detect a collision (platform) within safe distance, it's safe to jump
	if jump_check.is_colliding():
		var collision_point = jump_check.get_collision_point()
		var vertical_distance = collision_point.y - global_position.y
		return vertical_distance < SAFE_JUMP_DISTANCE
	
	return false
