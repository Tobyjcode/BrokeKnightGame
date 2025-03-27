extends AnimatableBody2D

@onready var sprite = $Sprite2D
var has_been_hit = false
var coin_scene = preload("res://coin.tscn")
var firefruit_scene = preload("res://firefruit.tscn")
@export var spawn_fire = true  # Set to true by default for testing

func _on_area_entered(body) -> void:
	if not has_been_hit and body is CharacterBody2D:
		var player = body
		# Check if player is below the box
		if player.global_position.y > global_position.y:
			# Use call_deferred to delay the spawn until it's safe
			call_deferred("spawn_item")
			has_been_hit = true
			# Change to empty box sprite
			sprite.region_rect.position.x = 16  # Move to next sprite in tileset

func spawn_item():
	if spawn_fire:
		var powerup = firefruit_scene.instantiate()
		powerup.global_position = global_position + Vector2(0, -16)
		get_parent().call_deferred("add_child", powerup)
		print("Fire fruit spawned!")
	else:
		var coin = coin_scene.instantiate()
		coin.global_position = global_position + Vector2(0, -16)
		get_parent().call_deferred("add_child", coin)
