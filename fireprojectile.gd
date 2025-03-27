extends Area2D

var speed = 400  # Increased speed
var direction = 1

func _ready():
	print("Fire projectile created at: ", global_position)  # Debug print
	add_to_group("fireballs")
	if has_node("Fire/AnimatedSprite2D"):
		$Fire/AnimatedSprite2D.play("Fire")
		print("Playing fire animation")  # Debug print
	else:
		push_error("Fire AnimatedSprite2D not found!")

func _physics_process(delta):
	# Move the projectile
	position.x += speed * direction * delta
	if has_node("Fire/AnimatedSprite2D"):
		$Fire/AnimatedSprite2D.flip_h = (direction < 0)

func set_direction(new_direction):
	direction = new_direction

# Handle collisions with both terrain and entities
func _on_body_entered(_body):  # Add underscore to indicate intentionally unused parameter
	print("Fireball hit terrain")  # Debug print
	queue_free()  # Destroy when hitting terrain

func _on_area_entered(area):
	print("Fireball hit area: ", area.name)  # Debug print
	if area.get_parent().has_method("take_damage"):
		area.get_parent().take_damage()
	queue_free()

# Delete when off screen
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free() 
