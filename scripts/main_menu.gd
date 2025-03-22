extends Control

func _ready():
	# Connect button signals
	$MenuContainer/StartButton.pressed.connect(_on_start_pressed)
	$MenuContainer/QuitButton.pressed.connect(_on_quit_pressed)
	
	# Set up keyboard navigation
	$MenuContainer/StartButton.grab_focus()

func _on_start_pressed():
	get_tree().change_scene_to_file("res://game.tscn")

func _on_quit_pressed():
	get_tree().quit()

# Handle keyboard/gamepad navigation
func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		if $MenuContainer/StartButton.has_focus():
			_on_start_pressed()
		elif $MenuContainer/QuitButton.has_focus():
			_on_quit_pressed() 
