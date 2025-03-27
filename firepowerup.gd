extends Area2D

@onready var animated_sprite = $Fire/AnimatedSprite2D
@onready var pickup_sound = $Firepowerpickupsound  # Updated to match the exact node name

func _ready():
	if animated_sprite:
		animated_sprite.play("Fire")
	else:
		push_error("AnimatedSprite2D not found!")
		
	# Add debug check for sound
	if pickup_sound:
		print("Pickup sound node found")
	else:
		push_error("Pickup sound node not found!")

func _on_body_entered(body):
	if body.has_method("is_player"):
		# Give fire power to player
		if body.has_method("equip_weapon"):
			var weapon = load("res://weapon.tscn").instantiate()
			body.add_child(weapon)
			body.equip_weapon(weapon)
			
			# Play pickup sound with debug
			if pickup_sound:
				print("Playing pickup sound")
				pickup_sound.play()
			else:
				push_error("Cannot play sound - pickup_sound is null")
			
			# Wait for sound to finish before removing powerup
			if pickup_sound:
				await pickup_sound.finished
			# Delete the powerup after collecting
			queue_free() 
