extends CharacterBody2D

@export var speed := 500.0


func _physics_process(_delta: float) -> void:
	var direction := Input.get_axis("ui_left", "ui_right")

	velocity.x = direction * speed
	velocity.y = 0.0

	move_and_slide()

	if direction < 0:
		$Sprite2D.flip_h = true
	elif direction > 0:
		$Sprite2D.flip_h = false
