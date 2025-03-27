extends Node2D

const SLIMESPEED = 60
const KILL_DISTANCE = 50  # How close you need to be to kill the slime

var direction = 1 
var game_manager: Node  # Add this line
var is_dying = false

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var player_in_range = false  # Track if player is in hitbox
var current_player = null    # Track the player reference

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Normal movement code
	if ray_cast_right.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
	if ray_cast_left.is_colliding():
		direction = 1
		animated_sprite.flip_h = false
	
	position.x += direction * SLIMESPEED * delta

func _ready():
	# Get GameManager reference like in coin.gd
	game_manager = get_node_or_null("/root/Game/GameManager")
	add_to_group("slimes")

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
