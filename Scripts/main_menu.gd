extends Control

func _on_single_player_button_pressed() -> void:
	get_tree().root.set_meta("game_mode", "single_player")
	get_tree().change_scene_to_file("res://Scenes/arkanoid.tscn")


func _on_two_players_button_pressed() -> void:
	get_tree().root.set_meta("game_mode", "two_players")
	get_tree().change_scene_to_file("res://Scenes/arkanoid.tscn")
