extends Control

func _ready():
	# Connect button signal
	$VBoxContainer/MenuButton.pressed.connect(_on_menu_pressed)
	
	# Set up keyboard navigation
	$VBoxContainer/MenuButton.grab_focus()
	
	# Access the static variables directly from GameManager script
	var GameManagerScript = load("res://game_manager.gd")
	print("Score:", GameManagerScript.score)  # Debug print
	print("Slimes:", GameManagerScript.slimes_killed)  # Debug print
	
	# Update the labels
	$VBoxContainer/ScoreContainer/CoinsLabel.text = "Coins: " + str(GameManagerScript.score)
	$VBoxContainer/ScoreContainer/SlimesLabel.text = "Slimes Defeated: " + str(GameManagerScript.slimes_killed)
	
	# Play victory sound
	var victory_sound = AudioStreamPlayer.new()
	victory_sound.stream = preload("res://toby_platformer_assets/medieval-fantasy-1/medieval-fantasy-1/sounds/victory-1.wav")
	add_child(victory_sound)
	victory_sound.play()

func _on_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

# Handle keyboard/gamepad navigation
func _unhandled_input(event):
	if event.is_action_pressed("ui_accept") and $VBoxContainer/MenuButton.has_focus():
		_on_menu_pressed() 
