extends Area2D

@onready var sprite = $Sprite2D
@onready var fire_sprite = $Fire/AnimatedSprite2D
@onready var pickup_sound = $Firepowerpickupsound

func _ready():
	if fire_sprite:
		fire_sprite.play("Fire")
	else:
		push_error("Fire sprite not found!")

func _on_body_entered(body):
	if body.has_method("is_player"):
		# Give fire power to player
		if body.has_method("enable_fire_power"):
			body.enable_fire_power()
			print("Fire power enabled for player!")  # Debug message
			
			# Play pickup sound
			if pickup_sound:
				pickup_sound.play()
				await pickup_sound.finished
			
			# Delete the powerup after collecting
			queue_free()
