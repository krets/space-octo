extends CanvasLayer

func _on_button_pressed() -> void:
	get_tree().paused = false
	print("Restarting?")
	get_tree().change_scene_to_file("res://scenes/Game.tscn")
