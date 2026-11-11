extends StaticBody2D

@export var hit_points := 1
@export var score_value := 100

@export var damaged_texture: Texture2D
@export var heavily_damaged_texture: Texture2D


func hit(player_id: int) -> void:
	hit_points -= 1

	if hit_points <= 0:
		destroy(player_id)
	else:
		update_visual()


func destroy(player_id: int) -> void:
	var level := get_parent()

	if level.has_method("brick_destroyed"):
		level.brick_destroyed(score_value, player_id)

	queue_free()


func update_visual() -> void:
	if hit_points == 2:
		if damaged_texture:
			$Sprite2D.texture = damaged_texture

	elif hit_points == 1:
		if heavily_damaged_texture:
			$Sprite2D.texture = heavily_damaged_texture
