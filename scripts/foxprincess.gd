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
		# Load GameManager script
		var GameManagerScript = load("res://game_manager.gd")
		print("Current score: ", GameManagerScript.score)  # Debug print
		
		# Check if player has enough coins
		if GameManagerScript.score >= 10:
			print("Victory - enough coins collected!")
			# Play victory sound
			var victory_sound = AudioStreamPlayer.new()
			victory_sound.stream = preload("res://toby_platformer_assets/medieval-fantasy-1/medieval-fantasy-1/sounds/victory-1.wav")
			add_child(victory_sound)
			victory_sound.play()
			
			# Wait for sound to start
			await get_tree().create_timer(0.1).timeout
			
			# Transition to victory screen
			get_tree().change_scene_to_file("res://scenes/victory_screen.tscn")
		else:
			# Create a temporary label to show the message
			var message = Label.new()
			message.text = "Collect " + str(10 - GameManagerScript.score) + " more coins to win!"
			message.position = Vector2(-100, -50)  # Position above the princess
			add_child(message)
			
			# Make the message fade out after 2 seconds
			var tween = create_tween()
			tween.tween_property(message, "modulate:a", 0.0, 2.0)
			tween.tween_callback(message.queue_free) 
