extends Node2D

@export var asteroid_timer_max : float = 15.0
@export var max_asteroids : int = 100

func _ready() -> void:
	var size = get_viewport().size
	$CanvasLayer/ColorRect.size = size
	# $CanvasLayer/Starfield.size = size


func reset_timer():
	$AsteroidSpawner.wait_time = randf_range(1.0, asteroid_timer_max)


func _on_asteroid_spawner_timeout() -> void:
	if $Asteroids.get_child_count() >= max_asteroids:
		$Asteroids.get_child(0).explode()

	var asteroid = preload("res://scenes/asteroid.tscn")
	var instance = asteroid.instantiate()
	var viewport_size = get_viewport().size
	var padding = 100
	
	# Get camera or player position as reference point
	var reference_pos = get_viewport().get_camera_2d().global_position  # or use player position
	
	# Randomly choose a side (0-3: top, right, bottom, left)
	var spawn_side = randi() % 4
	var spawn_pos = Vector2.ZERO
	
	match spawn_side:
		0: # Top
			spawn_pos.x = reference_pos.x + randf_range(-viewport_size.x/2 - padding, viewport_size.x/2 + padding)
			spawn_pos.y = reference_pos.y - viewport_size.y/2 - padding
		1: # Right
			spawn_pos.x = reference_pos.x + viewport_size.x/2 + padding
			spawn_pos.y = reference_pos.y + randf_range(-viewport_size.y/2 - padding, viewport_size.y/2 + padding)
		2: # Bottom
			spawn_pos.x = reference_pos.x + randf_range(-viewport_size.x/2 - padding, viewport_size.x/2 + padding)
			spawn_pos.y = reference_pos.y + viewport_size.y/2 + padding
		3: # Left
			spawn_pos.x = reference_pos.x - viewport_size.x/2 - padding
			spawn_pos.y = reference_pos.y + randf_range(-viewport_size.y/2 - padding, viewport_size.y/2 + padding)
	
	instance.global_position = spawn_pos
	$Asteroids.add_child(instance)
