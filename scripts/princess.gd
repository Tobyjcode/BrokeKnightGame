extends Area2D

func _ready():
	# Connect the body entered signal
	body_entered.connect(_on_body_entered)
	print("Princess area ready!")  # Debug print

func _on_body_entered(body):
	print("Body entered: ", body.name)  # Debug print
	if body.name == "Player":
		print("Player detected!")  # Debug print
		# Play victory sound
		var victory_sound = AudioStreamPlayer.new()
		victory_sound.stream = preload("res://toby_platformer_assets/medieval-fantasy-1/medieval-fantasy-1/sounds/victory-1.wav")
		add_child(victory_sound)
		victory_sound.play()
		
		# Wait for sound to start
		await get_tree().create_timer(0.1).timeout
		
		# Transition to victory screen
		get_tree().change_scene_to_file("res://scenes/victory_screen.tscn") 
