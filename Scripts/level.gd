extends Node2D

@export var normal_brick_scene: PackedScene
@export var medium_brick_scene: PackedScene
@export var hard_brick_scene: PackedScene

@export var score_label: Label
@export var lives_label: Label
@export var final_score_label: Label
@export var game_over_panel: Control

@export var starting_lives := 3

@export var brick_size := Vector2(140.0, 40.0)
@export var spacing := Vector2(10.0, 10.0)
@export var start_y := 200.0

@export var pause_menu_panel: Control
@export var double_ball_modifier_scene: PackedScene

@export var modifier_spawn_area := Rect2(
	Vector2(140, 260),
	Vector2(1640, 560)
)

@export var modifier_spawn_interval := 10.0

var active_double_ball_modifier: Node2D

var player1_score := 0
var player2_score := 0
var player1_lives := 0
var player2_lives := 0

var game_mode := "two_players"

var bricks_remaining := 0
var single_player_layout := [
	[3, 3, 3, 3, 3, 3, 3, 3, 3, 3],
	[3, 2, 2, 2, 2, 2, 2, 2, 2, 3],
	[2, 2, 1, 1, 1, 1, 1, 1, 2, 2],
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
]

var two_player_layout := [
	[3, 3, 2, 2, 0, 0, 2, 2, 3, 3],
	[3, 2, 2, 1, 0, 0, 1, 2, 2, 3],
	[2, 2, 1, 1, 0, 0, 1, 1, 2, 2],
	[2, 1, 1, 1, 0, 0, 1, 1, 1, 2],
	[1, 1, 1, 1, 0, 0, 1, 1, 1, 1],
	[2, 1, 1, 1, 0, 0, 1, 1, 1, 2],
	[3, 2, 2, 1, 0, 0, 1, 2, 2, 3]
]

@export var two_player_start_y := 320.0


func _ready() -> void:
	game_mode = str(
		get_tree().root.get_meta("game_mode", "two_players")
	)
	var top_wall := get_node_or_null("../Walls/Top")

	if top_wall:
		if game_mode == "single_player":
			top_wall.position.y = 20.0
		else:
			top_wall.position.y = -434.0
	player1_lives = starting_lives

	if game_mode == "two_players":
		player2_lives = starting_lives
	else:
		player2_lives = 0

		var player2_paddle := get_node_or_null("../Player2Paddle")

		if player2_paddle:
			player2_paddle.visible = false
			player2_paddle.set_physics_process(false)

			var collision_shape := player2_paddle.get_node_or_null("CollisionShape2D")

			if collision_shape:
				collision_shape.set_deferred("disabled", true)

	update_score_display()
	update_lives_display()
	create_bricks()
	start_modifier_spawning()

func update_score_display() -> void:
	if score_label:
		if game_mode == "single_player":
			score_label.text = "P1: " + str(player1_score)
		else:
			score_label.text = "P1: " + str(player1_score) + " | P2: " + str(player2_score)


func update_lives_display() -> void:
	if lives_label:
		if game_mode == "single_player":
			lives_label.text = "Lives: " + str(player1_lives)
		else:
			lives_label.text = "P1: " + str(player1_lives) + " | P2: " + str(player2_lives)

func create_bricks() -> void:
	var selected_layout: Array

	var layout_start_y := start_y

	if game_mode == "single_player":
		selected_layout = single_player_layout
	else:
		selected_layout = two_player_layout
		layout_start_y = two_player_start_y

	var rows: int = selected_layout.size()
	var columns: int = selected_layout[0].size()

	var total_width := (
		columns * brick_size.x
		+ (columns - 1) * spacing.x
	)

	var start_x := (
		1920.0 - total_width
	) / 2.0 + brick_size.x / 2.0

	for row in range(rows):
		for column in range(columns):
			var brick_type: int = selected_layout[row][column]

			if brick_type == 0:
				continue

			var brick_scene: PackedScene

			match brick_type:
				1:
					brick_scene = normal_brick_scene
				2:
					brick_scene = medium_brick_scene
				3:
					brick_scene = hard_brick_scene
				_:
					continue

			var brick := brick_scene.instantiate()

			add_child(brick)

			brick.position = Vector2(
				start_x + column * (brick_size.x + spacing.x),
				layout_start_y + row * (brick_size.y + spacing.y)
			)

			bricks_remaining += 1

func brick_destroyed(score_value: int, player_id: int) -> void:
	bricks_remaining -= 1

	if player_id == 1:
		player1_score += score_value
	elif player_id == 2:
		player2_score += score_value

	update_score_display()

	print("Player 1 Score: ", player1_score)
	print("Player 2 Score: ", player2_score)
	print("Bricks remaining: ", bricks_remaining)

	if bricks_remaining <= 0:
		level_complete()


func level_complete() -> void:
	print("LEVEL COMPLETE!")


func ball_lost(player_id: int) -> void:
	if player_id == 1:
		player1_lives -= 1
	elif player_id == 2:
		player2_lives -= 1

	update_lives_display()

	print("Player 1 lives: ", player1_lives)
	print("Player 2 lives: ", player2_lives)

	if game_mode == "single_player":
		if player1_lives <= 0:
			game_over(0)
	else:
		if player1_lives <= 0 or player2_lives <= 0:
			if player1_score > player2_score:
				game_over(1)
			elif player2_score > player1_score:
				game_over(2)
			else:
				game_over(0)

func game_over(winner_id: int) -> void:
	if game_mode == "single_player":
		print("GAME OVER!")

		if final_score_label:
			final_score_label.text = (
                "GAME OVER!\n"
				+ "Final Score: " + str(player1_score)
			)

	else:
		if winner_id == 0:
			print("IT'S A DRAW!")
		else:
			print("PLAYER ", winner_id, " WINS!")

		if final_score_label:
			if winner_id == 0:
				final_score_label.text = (
                    "IT'S A DRAW!\n"
					+ "P1 Score: " + str(player1_score) + "\n"
					+ "P2 Score: " + str(player2_score)
				)
			else:
				final_score_label.text = (
					"PLAYER " + str(winner_id) + " WINS!\n"
					+ "P1 Score: " + str(player1_score) + "\n"
					+ "P2 Score: " + str(player2_score)
				)

	if game_over_panel:
		game_over_panel.visible = true

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if get_tree().paused:
			resume_game()
		else:
			pause_game()

func pause_game() -> void:
	get_tree().paused = true
	if pause_menu_panel:
		pause_menu_panel.visible = true

func resume_game() -> void:
	if pause_menu_panel:
		pause_menu_panel.visible = false
	get_tree().paused = false

func _on_resume_button_pressed() -> void:
	resume_game()

func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func start_modifier_spawning() -> void:
	var timer := Timer.new()
	timer.wait_time = modifier_spawn_interval
	timer.timeout.connect(spawn_double_ball_modifier)

	add_child(timer)
	timer.start()


func spawn_double_ball_modifier() -> void:
	# Don't spawn another if one is already active.
	if is_instance_valid(active_double_ball_modifier):
		return

	if double_ball_modifier_scene == null:
		return

	var modifier := double_ball_modifier_scene.instantiate() as Node2D

	add_child(modifier)

	var random_position := Vector2(
		randf_range(
			modifier_spawn_area.position.x,
			modifier_spawn_area.end.x
		),
		randf_range(
			modifier_spawn_area.position.y,
			modifier_spawn_area.end.y
		)
	)

	modifier.global_position = random_position
	active_double_ball_modifier = modifier
