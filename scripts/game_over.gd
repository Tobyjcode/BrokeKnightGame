extends Control

func _ready():
	# Connect button signals
	$VBoxContainer/RetryButton.pressed.connect(_on_retry_pressed)
	$VBoxContainer/MenuButton.pressed.connect(_on_main_menu_pressed)
	
	# Set up keyboard navigation
	$VBoxContainer/RetryButton.grab_focus()

func _on_retry_pressed():
	get_tree().change_scene_to_file("res://game.tscn")

func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

# Handle keyboard/gamepad navigation
func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		if $VBoxContainer/RetryButton.has_focus():
			_on_retry_pressed()
		elif $VBoxContainer/MenuButton.has_focus():
			_on_main_menu_pressed()