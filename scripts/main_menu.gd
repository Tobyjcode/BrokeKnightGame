extends Control

func _ready():
	# Connect button signals
	$MenuContainer/StartButton.pressed.connect(_on_start_pressed)
	$MenuContainer/QuitButton.pressed.connect(_on_quit_pressed)
	
	# Set up keyboard/controller navigation
	$MenuContainer/StartButton.grab_focus()

func _on_start_pressed():
	# Load and use GameManager script
	var GameManagerScript = load("res://game_manager.gd")
	GameManagerScript.reset_scores()
	print("Scores reset - starting fresh game!")  # Debug print
	
	# Change to game scene
	get_tree().change_scene_to_file("res://game.tscn")

func _on_quit_pressed():
	get_tree().quit()

# Handle keyboard/gamepad navigation
func _unhandled_input(event):
	# Handle both keyboard and PS4 controller inputs
	if event.is_action_pressed("ui_accept") or (event is InputEventJoypadButton and event.button_index == 0):  # 0 is the X button on PS4
		if $MenuContainer/StartButton.has_focus():
			_on_start_pressed()
		elif $MenuContainer/QuitButton.has_focus():
			_on_quit_pressed()
	
	# Handle controller stick/d-pad navigation
	if event.is_action_pressed("ui_down"):
		if $MenuContainer/StartButton.has_focus():
			$MenuContainer/QuitButton.grab_focus()
	elif event.is_action_pressed("ui_up"):
		if $MenuContainer/QuitButton.has_focus():
			$MenuContainer/StartButton.grab_focus() 
