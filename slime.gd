extends CharacterBody2D  # or whatever your slime's base node is

func die():
	# Get reference to GameManager and increment slime count
	var game_manager = get_node("/root/GameManager")
	game_manager.add_slime_kill()
	
	# Add any death animation or effects here
	queue_free()  # Remove the slime from the scene 

func _on_hitbox_area_entered(area):
	if area.is_in_group("player_attack"):
		die() 