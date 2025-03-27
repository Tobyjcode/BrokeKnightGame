func _ready():
	# Remove or comment out the old princess code
	# var princess_scene = preload("res://scenes/princess.tscn")
	# var princess = princess_scene.instantiate()
	
	# Add the fox princess instead
	var foxprincess_scene = preload("res://foxprincess.tscn")
	var foxprincess = foxprincess_scene.instantiate()
	print("Adding fox princess to game")  # Debug print
	# Set the fox princess position where you want her to appear
	foxprincess.position = Vector2(1000, 300)  # Adjust these coordinates
	add_child(foxprincess) 