extends Area2D

var game_manager: Node
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	# Try to find the GameManager in the scene
	game_manager = get_node_or_null("/root/Game/GameManager")

func _on_body_entered(body):
	if game_manager:
		game_manager.add_point()
	animation_player.play("pickupcoin")
