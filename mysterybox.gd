extends AnimatableBody2D

@onready var sprite = $Sprite2D
var has_been_hit = false
var coin_scene = preload("res://coin.tscn")

func _on_area_entered(body) -> void:
	if not has_been_hit and body is CharacterBody2D:
		var player = body
		# Check if player is below the box
		if player.global_position.y > global_position.y:
			spawn_item()
			has_been_hit = true
			# Change to empty box sprite
			sprite.region_rect.position.x = 16  # Move to next sprite in tileset

func spawn_item():
	var coin = coin_scene.instantiate()
	# Position the coin above the box
	coin.global_position = global_position + Vector2(0, -16)
	get_parent().add_child(coin)
