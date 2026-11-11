extends CharacterBody2D

@export var speed := 500.0
@export var player_id := 1

func _ready() -> void:
	add_to_group("paddle")
	
func _physics_process(_delta: float) -> void:
	var direction := 0.0
	if player_id == 1:
		direction = Input.get_axis("p1_left", "p1_right")
	else:
		direction = Input.get_axis("p2_left", "p2_right")
		
	velocity.x = direction * speed
	velocity.y = 0.0

	move_and_slide()

	if direction < 0:
		$Sprite2D.flip_h = true
	elif direction > 0:
		$Sprite2D.flip_h = false
