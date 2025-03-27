extends Area2D

@export_multiline var sign_text: String = "Hint: Falling hurts... Watch your step!"
var is_player_in_range := false

func _ready():
	# Connect the body entered/exited signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Hide the hint text initially
	$HintText.hide()
	
	# Add a small bounce animation to the sign
	var tween = create_tween()
	tween.set_loops()  # Make it loop forever
	tween.tween_property($Sprite2D, "position:y", -2.0, 1.0)
	tween.tween_property($Sprite2D, "position:y", 0.0, 1.0)

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("is_player"):
		is_player_in_range = true
		# Show hint text with a nice fade in
		$HintText.text = sign_text  # Set the text
		$HintText.modulate.a = 0  # Start fully transparent
		$HintText.show()  # Make visible
		var tween = create_tween()
		tween.tween_property($HintText, "modulate:a", 1.0, 0.3)  # Fade in

func _on_body_exited(body: Node2D) -> void:
	if body.has_method("is_player"):
		is_player_in_range = false
		# Fade out hint text
		var tween = create_tween()
		tween.tween_property($HintText, "modulate:a", 0.0, 0.3)
		tween.tween_callback($HintText.hide) 