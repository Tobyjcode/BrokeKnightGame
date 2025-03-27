extends Area2D

var speed = 300  # Adjust this value to change projectile speed
var direction = 1

func _ready():
    # Make sure the fire animation plays
    if $Fire/AnimatedSprite2D:
        $Fire/AnimatedSprite2D.play("Fire")

func _physics_process(delta):
    # Move the projectile
    position.x += speed * direction * delta

func set_direction(new_direction):
    direction = new_direction
    # Flip the sprite if going left
    if has_node("Fire/AnimatedSprite2D"):
        $Fire/AnimatedSprite2D.flip_h = (direction < 0)

# Delete the projectile when it hits something
func _on_body_entered(body):
    if body.has_method("take_damage"):
        body.take_damage()
    queue_free()

# Delete when off screen
func _on_visible_on_screen_notifier_2d_screen_exited():
    queue_free() 