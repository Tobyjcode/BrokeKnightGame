extends Node

func _ready():
    # Set up keyboard/controller navigation
    if has_node("MenuContainer/StartButton"):
        $MenuContainer/StartButton.grab_focus()

func _on_start_pressed() -> void:
    # Load and reset game manager first
    var game_manager_path = "res://game_manager.gd"
    if ResourceLoader.exists(game_manager_path):
        var GameManagerScript = load(game_manager_path)
        if GameManagerScript:
            GameManagerScript.reset_scores()
    
    # Try loading game scene
    var game_path = "res://game.tscn"
    if ResourceLoader.exists(game_path):
        get_tree().change_scene_to_file(game_path)
    else:
        game_path = "res://scenes/game.tscn"
        if ResourceLoader.exists(game_path):
            get_tree().change_scene_to_file(game_path)
        else:
            push_error("Could not find game scene at either location")

func _on_quit_pressed():
    get_tree().quit()

func _unhandled_input(event):
    if event is InputEventKey:
        if event.pressed and event.keycode == KEY_ESCAPE:
            _on_quit_pressed()