extends Node

# Make these static so they persist between scene changes
static var score = 0
static var slimes_killed = 0
var score_label
var slime_label

func _ready():
	print("GameManager initialized")  # Debug print
	print("Initial score:", score)  # Debug print
	print("Initial slimes:", slimes_killed)  # Debug print
	
	# Add the UI as a child of GameManager
	var game_ui = preload("res://game_ui.tscn").instantiate()
	add_child(game_ui)
	
	# Get the label references AFTER adding the UI
	score_label = game_ui.get_node("MarginContainer/HBoxContainer/CoinCounter/ScoreLabel")
	slime_label = game_ui.get_node("MarginContainer/HBoxContainer/SlimeCounter/SlimeLabel")
	
	update_labels()

func add_point():
	score += 1
	print("Score increased to:", score)  # Debug print
	update_labels()

func add_slime_kill():
	slimes_killed += 1
	print("Slimes killed:", slimes_killed)  # Debug print
	update_labels()

func update_labels():
	if score_label:
		score_label.text = ": " + str(score)
	if slime_label:
		slime_label.text = ": " + str(slimes_killed)
