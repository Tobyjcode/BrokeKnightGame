extends Node2D

@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var slash_sprite = $SlashSprite

var is_attacking = false
var attack_cooldown = 0.2
var can_attack = true
var fire_projectile_scene = preload("res://fireprojectile.tscn")

func _ready():
	# Initialize at reset position
	animation_player.play("RESET")
	# Hide slash sprite initially
	if slash_sprite:
		slash_sprite.hide()

func _process(_delta):
	if Input.is_action_just_pressed("attack"):
		attack()
	
	# Update weapon and slash effect direction based on player direction
	var parent = get_parent()
	if parent and parent.has_method("is_player"):
		if parent.animated_sprite.flip_h:
			scale.x = -1  # Flip weapon when player faces left
			position.x = -8  # Hold on left side
		else:
			scale.x = 1   # Normal scale when player faces right
			position.x = 8  # Hold on right side
			
	# Update slash effect position during attack
	if is_attacking and slash_sprite:
		slash_sprite.rotation = sprite.rotation

func attack():
	if can_attack and not is_attacking:
		is_attacking = true
		can_attack = false
		
		# Show and start slash effect
		if slash_sprite:
			slash_sprite.show()
			slash_sprite.play("slash")
			slash_sprite.rotation = sprite.rotation
		
		# Play the weapon attack animation
		animation_player.stop()
		animation_player.play("attack")
		
		# Shoot fire projectile if player has fire power
		var parent = get_parent()
		if parent.has_method("is_player") and parent.has_fire_power:
			shoot_fire_projectile()
		
		# Wait for animation to finish
		await animation_player.animation_finished
		
		# Hide slash effect
		if slash_sprite:
			slash_sprite.hide()
			
		is_attacking = false
		await get_tree().create_timer(attack_cooldown).timeout
		can_attack = true

func shoot_fire_projectile():
	var projectile = fire_projectile_scene.instantiate()
	var parent = get_parent()
	if parent and parent.has_method("is_player"):
		# Spawn the projectile in front of the player
		var spawn_offset = Vector2(20, 0)
		if parent.animated_sprite.flip_h:
			spawn_offset.x *= -1
			projectile.set_direction(-1)
		projectile.global_position = global_position + spawn_offset
		get_tree().current_scene.add_child(projectile)
