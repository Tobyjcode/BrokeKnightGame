extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)
	print("Fox Princess ready!")  # Debug print
	print("Collision mask: ", collision_mask)  # Debug print
	print("Monitoring: ", monitoring)  # Debug print

func _on_body_entered(body):
	print("Body entered: ", body.name)  # Debug print
	print("Body collision layer: ", body.collision_layer)  # Debug print
	if body is CharacterBody2D:  # Check if it's any character body
		print("Victory!")
		# Play victory sound
		var victory_sound = AudioStreamPlayer.new()
		victory_sound.stream = preload("res://toby_platformer_assets/medieval-fantasy-1/medieval-fantasy-1/sounds/victory-1.wav")
		add_child(victory_sound)
		victory_sound.play()
		
		# Wait for sound to start
		await get_tree().create_timer(0.1).timeout
		
		# Transition to victory screen
		get_tree().change_scene_to_file("res://scenes/victory_screen.tscn") 
