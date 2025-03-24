extends Node

var score = 0
@onready var score_label = $ScoreLabel

func add_point():
	score += 1
	if score_label:
		score_label.text = "Coins collected: " + str(score) + " ✨"
	print("You found a coin! Total: ", score)  # Fallback if no label exists
