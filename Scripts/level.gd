extends Node2D

@export var normal_brick_scene: PackedScene
@export var medium_brick_scene: PackedScene
@export var hard_brick_scene: PackedScene

@export var score_label: Label
@export var lives_label: Label
@export var final_score_label: Label
@export var game_over_panel: Control

@export var starting_lives := 3

@export var brick_size := Vector2(70.0, 20.0)
@export var spacing := Vector2(5.0, 5.0)
@export var start_y := 100.0


var score := 0
var lives := 0
var bricks_remaining := 0


var level_layout := [
	[3, 3, 3, 3, 3, 3, 3, 3, 3, 3],
	[3, 2, 2, 2, 2, 2, 2, 2, 2, 3],
	[3, 2, 1, 1, 1, 1, 1, 1, 2, 3],
	[2, 2, 1, 1, 1, 1, 1, 1, 2, 2],
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
]


func _ready() -> void:
	lives = starting_lives

	update_score_display()
	update_lives_display()

	create_bricks()


func update_score_display() -> void:
	if score_label:
		score_label.text = "SCORE: " + str(score)


func update_lives_display() -> void:
	if lives_label:
		lives_label.text = "LIVES: " + str(lives)


func create_bricks() -> void:
	var rows: int = level_layout.size()
	var columns: int = level_layout[0].size()

	var total_width := (
		columns * brick_size.x
		+ (columns - 1) * spacing.x
	)

	var start_x := (
		960.0 - total_width
	) / 2.0 + brick_size.x / 2.0

	for row in rows:
		for column in columns:
			var brick_type: int = level_layout[row][column]

			# 0 means no brick.
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
				start_y + row * (brick_size.y + spacing.y)
			)

			bricks_remaining += 1


func brick_destroyed(score_value: int) -> void:
	bricks_remaining -= 1
	score += score_value

	update_score_display()

	print("Score: ", score)
	print("Bricks remaining: ", bricks_remaining)

	if bricks_remaining <= 0:
		level_complete()


func level_complete() -> void:
	print("LEVEL COMPLETE!")


func ball_lost() -> void:
	if lives <= 0:
		return

	lives -= 1

	update_lives_display()

	print("Lives remaining: ", lives)

	if lives <= 0:
		game_over()


func game_over() -> void:
	print("GAME OVER!")

	if final_score_label:
		final_score_label.text = "SCORE: " + str(score)

	if game_over_panel:
		game_over_panel.visible = true


func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()
