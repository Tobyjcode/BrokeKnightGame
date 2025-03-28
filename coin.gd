extends Area2D

var game_manager: Node
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	# Try to find the GameManager in the scene
	game_manager = get_node("/root/Game/GameManager")
	if !game_manager:
		print("Looking for GameManager in alternate location")
		game_manager = get_node("/root/GameManager")

func _on_body_entered(_body):
	if game_manager:
		print("Adding point, current score: ", game_manager.score)
		game_manager.add_point()
	animation_player.play("pickupcoin")
