extends Node2D


func _process(delta: float) -> void:
	$Label.text = "%0.1f" % Engine.get_frames_per_second() 
