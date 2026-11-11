extends CharacterBody2D

@export var speed := 350.0

var launched := false
var last_player_id := 0

func _process(_delta: float) -> void:
	if not launched:
		return

	var game_mode := str(
		get_tree().root.get_meta("game_mode", "two_players")
	)

	# Player 1 loses the ball at the bottom.
	if global_position.y > 560.0:
		print("Player 1 missed!")
		ball_lost(1)

	# Only check the top boundary in two-player mode.
	elif game_mode == "two_players" and global_position.y < -20.0:
		print("Player 2 missed!")
		ball_lost(2)
		
func _physics_process(delta: float) -> void:
	if not launched:
		global_position = Vector2(480, 462)

		if Input.is_action_just_pressed("ui_accept"):
			launched = true
			velocity = Vector2.UP * speed
		return

	var collision := move_and_collide(velocity * delta)

	if collision:
		var collider := collision.get_collider()

		if collider.is_in_group("brick"):
			collider.hit(last_player_id)
			velocity = velocity.bounce(collision.get_normal()).normalized() * speed

		elif collider.is_in_group("paddle"):
			bounce_from_paddle(collider)

		else:
			velocity = velocity.bounce(collision.get_normal()).normalized() * speed


func bounce_from_paddle(paddle: CharacterBody2D) -> void:
	last_player_id = paddle.player_id
	print("Last hit by Player: ", last_player_id)
	var paddle_width := 120.0

	# How far from the center did the ball hit?
	var hit_position := global_position.x - paddle.global_position.x

	# Convert the hit position to -1.0 (left) to 1.0 (right).
	var normalized_hit := hit_position / (paddle_width / 2.0)
	normalized_hit = clamp(normalized_hit, -1.0, 1.0)

	# Maximum angle from vertical.
	var max_angle := deg_to_rad(60.0)

	# Minimum angle so the ball never travels perfectly vertically.
	var min_angle := deg_to_rad(15.0)

	var angle := normalized_hit * max_angle

	# If the ball hits close to the center,
	# force a minimum horizontal angle.
	if abs(angle) < min_angle:
		if normalized_hit < 0.0:
			angle = -min_angle
		elif normalized_hit > 0.0:
			angle = min_angle
		else:
			# Exact center: randomly choose left or right.
			angle = min_angle if randf() < 0.5 else -min_angle

	var vertical_direction := -1.0 if paddle.player_id == 1 else 1.0
	velocity = Vector2(sin(angle), vertical_direction * cos(angle)).normalized() * speed


func ball_lost(player_id: int) -> void:
	if not launched:
		return

	launched = false
	velocity = Vector2.ZERO

	print("BALL LOST")

	var level := get_node("../Level")

	if level.has_method("ball_lost"):
		level.ball_lost(player_id)
