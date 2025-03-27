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
			# Create first message
			var message1 = Label.new()
			message1.text = "No Money No Princesses"
			message1.position = Vector2(-100, -70)  # Slightly higher position
			add_child(message1)
			
			# Create second message
			var message2 = Label.new()
			message2.text = str(10 - GameManagerScript.score) + " more coins to win!"
			message2.position = Vector2(-100, -40)  # Lower position
			message2.modulate.a = 0  # Start invisible
			add_child(message2)
			
			# Fade in/out sequence
			var tween = create_tween()
			tween.tween_property(message1, "modulate:a", 1.0, 0.3)  # Fade in first message
			tween.tween_interval(1.0)  # Wait a second
			tween.tween_property(message2, "modulate:a", 1.0, 0.3)  # Fade in second message
			tween.tween_interval(2.0)  # Wait two seconds
			tween.tween_property(message1, "modulate:a", 0.0, 0.3)  # Fade out first message
			tween.tween_property(message2, "modulate:a", 0.0, 0.3)  # Fade out second message
			tween.tween_callback(message1.queue_free)  # Clean up
			tween.tween_callback(message2.queue_free) 
