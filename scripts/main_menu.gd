extends Control

func _ready() -> void:
	# Connect button signals
	$MenuContainer/StartButton.pressed.connect(_on_start_pressed)
	$MenuContainer/QuitButton.pressed.connect(_on_quit_pressed)
	$MenuContainer/FullscreenButton.pressed.connect(_on_fullscreen_pressed)
	
	# Set up keyboard/controller navigation
	$MenuContainer/StartButton.grab_focus()
	
	# Web-specific setup
	if OS.has_feature("web"):
		$MenuContainer/QuitButton.hide()
		
		# Set up viewport scaling that maintains your preferred aspect ratio
		get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
		get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
		
		# Calculate scale to fit browser window while maintaining aspect ratio
		var window_size = DisplayServer.window_get_size()
		var scale_w = window_size.x / 1908.0
		var scale_h = window_size.y / 962.0
		var scale = min(scale_w, scale_h)
		
		# Apply the calculated scale
		get_tree().root.content_scale_factor = scale
		
		# Add window resize handling
		get_window().size_changed.connect(_on_window_size_changed)

func _on_start_pressed() -> void:
	var GameManagerScript = load("res://game_manager.gd")
	if GameManagerScript:
		GameManagerScript.reset_scores()
	
	# Try loading game scene from root directory
	var error = get_tree().change_scene_to_file("res://game.tscn")
	if error != OK:
		print("Failed to load game scene from root, trying scenes folder...")
		error = get_tree().change_scene_to_file("res://scenes/game.tscn")
		if error != OK:
			print("Failed to load game scene. Error: ", error)
const SLIMER = preload("res://slimer.tscn")
func _on_quit_pressed():
	get_tree().quit()

func _on_fullscreen_pressed() -> void:
	if OS.has_feature("web"):
		# Web fullscreen
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		# Desktop fullscreen
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

# Handle keyboard/gamepad navigation
func _unhandled_input(event):
	# Handle both keyboard and PS4 controller inputs
	if event.is_action_pressed("ui_accept") or (event is InputEventJoypadButton and event.button_index == 0):  # 0 is the X button on PS4
		if $MenuContainer/StartButton.has_focus():
			_on_start_pressed()
		elif $MenuContainer/QuitButton.has_focus():
			_on_quit_pressed()
		elif $MenuContainer/FullscreenButton.has_focus():
			_on_fullscreen_pressed()
	
	# Handle controller stick/d-pad navigation
	if event.is_action_pressed("ui_down"):
		if $MenuContainer/StartButton.has_focus():
			$MenuContainer/QuitButton.grab_focus()
		elif $MenuContainer/QuitButton.has_focus():
			$MenuContainer/FullscreenButton.grab_focus()
	elif event.is_action_pressed("ui_up"):
		if $MenuContainer/FullscreenButton.has_focus():
			$MenuContainer/QuitButton.grab_focus()
		elif $MenuContainer/QuitButton.has_focus():
			$MenuContainer/StartButton.grab_focus()

func _on_window_size_changed():
	if OS.has_feature("web"):
		var window_size = DisplayServer.window_get_size()
		var scale_w = window_size.x / 1908.0
		var scale_h = window_size.y / 962.0
		var scale = min(scale_w, scale_h)
		get_tree().root.content_scale_factor = scale
