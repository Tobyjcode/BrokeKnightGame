extends Area2D

@onready var animated_sprite = $Fire/AnimatedSprite2D

func _ready():
	if animated_sprite:
		animated_sprite.play("Fire")
	else:
		push_error("AnimatedSprite2D not found!")

func _on_body_entered(body):
	if body.has_method("is_player"):
		# Give fire power to player
		if body.has_method("equip_weapon"):
			var weapon = load("res://weapon.tscn").instantiate()
			body.add_child(weapon)
			body.equip_weapon(weapon)
			# Delete the powerup after collecting
			queue_free() 
