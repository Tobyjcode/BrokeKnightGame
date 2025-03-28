extends Control

func _ready():
	# Connect button signals
	$VBoxContainer/RetryButton.pressed.connect(_on_retry_pressed)
	$VBoxContainer/MenuButton.pressed.connect(_on_main_menu_pressed)
	
	# Set up keyboard/controller navigation
	$VBoxContainer/RetryButton.grab_focus()

func _unhandled_input(event):
	# Handle both keyboard and PS4 controller inputs
	if event.is_action_pressed("ui_accept") or (event is InputEventJoypadButton and event.button_index == 0):  # 0 is X button on PS4
		if $VBoxContainer/RetryButton.has_focus():
			_on_retry_pressed()
		elif $VBoxContainer/MenuButton.has_focus():
			_on_main_menu_pressed()
	
	# Handle controller stick/d-pad navigation
	if event.is_action_pressed("ui_down"):
		if $VBoxContainer/RetryButton.has_focus():
			$VBoxContainer/MenuButton.grab_focus()
	elif event.is_action_pressed("ui_up"):
		if $VBoxContainer/MenuButton.has_focus():
			$VBoxContainer/RetryButton.grab_focus()

func _on_retry_pressed():
	get_tree().change_scene_to_file("res://game.tscn")

func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")