extends Area2D

var speed = 400  # Increased speed
var direction = 1

func _ready():
    print("Fire projectile created at: ", global_position)  # Debug print
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

# Delete the projectile when it hits something
func _on_body_entered(body):
    if body.has_method("take_damage"):
        body.take_damage()
    queue_free()

# Delete when off screen
func _on_visible_on_screen_notifier_2d_screen_exited():
    queue_free() 