extends Area2D

@export var speed = 200
@export var direction = 1  # Add @export to make it settable from outside

func _ready():
    var timer = get_tree().create_timer(2.0)  # Destroy after 2 seconds
    await timer.timeout
    queue_free()

func set_direction(new_direction: int):
    direction = new_direction

func _physics_process(delta):
    position += Vector2(speed * direction * delta, 0)

func _on_body_entered(body):
    if body.has_method("take_damage"):
        body.take_damage()
    queue_free()

# Optional: Add this to destroy the projectile after some time
func _on_lifetime_timeout():
    queue_free() 