extends Node2D

@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer

var is_attacking = false
var attack_cooldown = 0.2
var can_attack = true

func _ready():
	# Initialize at reset position
	animation_player.play("RESET")

func _process(_delta):
	if Input.is_action_just_pressed("attack"):
		attack()
	
	# Update weapon direction based on player direction
	var parent = get_parent()
	if parent and parent.has_method("is_player"):
		if parent.animated_sprite.flip_h:
			scale.x = -1  # Flip weapon when player faces left
			position.x = -8  # Hold on left side
		else:
			scale.x = 1   # Normal scale when player faces right
			position.x = 8  # Hold on right side

func attack():
	if can_attack and not is_attacking:
		is_attacking = true
		can_attack = false
		
		# Play the attack animation
		animation_player.stop()
		animation_player.play("attack")
		
		await animation_player.animation_finished
		is_attacking = false
		await get_tree().create_timer(attack_cooldown).timeout
		can_attack = true
