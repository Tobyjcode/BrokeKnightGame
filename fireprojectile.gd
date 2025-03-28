extends Area2D

var speed: float = 400.0  # Changed to float
var direction: float = 1.0  # Changed to float
@onready var explosion_sound = $ExplosionSound
@onready var shoot_sound = $ShootSound

func _ready():
	print("Fire projectile created at: ", global_position)  # Debug print
	add_to_group("fireballs")
	if has_node("Fire/AnimatedSprite2D"):
		$Fire/AnimatedSprite2D.play("Fire")
	
	# Play shoot sound when created
	if shoot_sound:
		shoot_sound.play()  # Just play it, don't wait

func _physics_process(delta: float) -> void:
	# Move the projectile
	position.x += speed * direction * delta
	if has_node("Fire/AnimatedSprite2D"):
		$Fire/AnimatedSprite2D.flip_h = (direction < 0)

func set_direction(new_direction):
	direction = new_direction

# Handle collisions with both terrain and entities
func _on_body_entered(_body):
	print("Fireball hit terrain")  # Debug print
	if shoot_sound and shoot_sound.playing:
		await shoot_sound.finished
	queue_free()

func _on_area_entered(area):
	print("Fireball hit area: ", area.name)  # Debug print
	if area.name == "Hitbox" and area.get_parent().is_in_group("slimes"):
		print("Hit a slime!")  # Debug print
		area.get_parent().take_damage()
		
		# Debug prints for sound status
		print("Explosion sound node exists:", explosion_sound != null)
		if explosion_sound:
			print("Playing explosion sound")
			explosion_sound.play()
			await explosion_sound.finished
			print("Explosion sound finished")
		else:
			print("No explosion sound node found!")
			
		queue_free()
	else:
		queue_free()

# Delete when off screen
func _on_visible_on_screen_notifier_2d_screen_exited():
	if shoot_sound and shoot_sound.playing:  # Wait for shoot sound if it's still playing
		await shoot_sound.finished
	queue_free() 
