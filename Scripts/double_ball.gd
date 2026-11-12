
extends StaticBody2D

var activated := false


func activate(ball: CharacterBody2D) -> void:
	if activated:
		return

	activated = true

	# Duplicate the existing ball, including its children and script.
	var new_ball := ball.duplicate() as CharacterBody2D

	if new_ball == null:
		return

	# Add it to the same parent as the original ball.
	ball.get_parent().add_child(new_ball)

	# Start at the original ball's current position.
	new_ball.global_position = ball.global_position

	# Travel in the exact opposite direction.
	new_ball.velocity = -ball.velocity
	new_ball.launched = true

	# Preserve the ball's existing scoring attribution.
	new_ball.last_player_id = ball.last_player_id

	# Remove the modifier after activation.
	queue_free()
