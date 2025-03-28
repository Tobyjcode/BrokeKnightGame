extends Area2D

var attempt_count = 0  # Track number of attempts
@onready var animated_sprite = $Princess  # Reference to AnimatedSprite2D
var is_attacking = false

func _ready():
	body_entered.connect(_on_body_entered)
	print("Fox Princess ready!")  # Debug print
	print("Collision mask: ", collision_mask)  # Debug print
	print("Monitoring: ", monitoring)  # Debug print
	
	# Connect to animation finished signal
	animated_sprite.animation_finished.connect(_on_animation_finished)

func kill_player(player: Node2D):
	# Disable player controls
	player.set_physics_process(false)
	if player.has_method("play_hurt_animation"):
		player.play_hurt_animation()
	
	# Remove player collision to prevent further interactions
	player.get_node("CollisionShape2D").set_deferred("disabled", true)

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
			attempt_count += 1
			
			if attempt_count >= 3:
				# Kill player for being too poor
				print("Death by poverty!")
				Engine.time_scale = 0.5
				
				# Play attack animation
				animated_sprite.play("attack")
				is_attacking = true
				
				# Create death message with style
				var death_message = Label.new()
				death_message.text = "Eliminated for being broke!"
				death_message.position = Vector2(-100, -70)
				death_message.modulate = Color(1, 0, 0)  # Red text
				add_child(death_message)
				
				# Kill the player
				kill_player(body)
				
				# Reset scores
				GameManagerScript.reset_scores()
				
				# Wait for animation and show message
				await get_tree().create_timer(1.0).timeout
				
				# Add second message
				var death_message2 = Label.new()
				death_message2.text = "Should've gotten a job..."
				death_message2.position = Vector2(-100, -40)
				death_message2.modulate = Color(1, 0, 0)  # Red text
				add_child(death_message2)
				
				# Wait a moment then go to game over
				await get_tree().create_timer(2.0).timeout
				Engine.time_scale = 1
				get_tree().change_scene_to_file("res://scenes/game_over.tscn")
			else:
				# Create first message
				var message1 = Label.new()
				message1.text = "No Money No Princesses"
				message1.position = Vector2(-100, -70)
				add_child(message1)
				
				# Create second message
				var message2 = Label.new()
				message2.text = str(10 - GameManagerScript.score) + " more coins to win!"
				message2.position = Vector2(-100, -40)
				message2.modulate.a = 0
				add_child(message2)
				
				# Fade in/out sequence
				var tween = create_tween()
				tween.tween_property(message1, "modulate:a", 1.0, 0.3)
				tween.tween_interval(1.0)
				tween.tween_property(message2, "modulate:a", 1.0, 0.3)
				tween.tween_interval(2.0)
				tween.tween_property(message1, "modulate:a", 0.0, 0.3)
				tween.tween_property(message2, "modulate:a", 0.0, 0.3)
				tween.tween_callback(message1.queue_free)
				tween.tween_callback(message2.queue_free)

func _on_animation_finished():
	if is_attacking:
		is_attacking = false
		animated_sprite.play("default")  # Return to default animation 
