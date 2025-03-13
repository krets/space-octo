extends Node2D

@export var asteroid_timer_max : float = 15.0
@export var max_asteroids : int = 100

func _ready() -> void:
	var size = get_viewport().size
	$CanvasLayer/ColorRect.size = size
	# $CanvasLayer/Starfield.size = size
	print(ColorPalette.new().colors)
	

func _on_asteroid_spawner_timeout() -> void:
	$AsteroidSpawner.wait_time = randf_range(1.0, asteroid_timer_max)
	if $Asteroids.get_child_count() >= max_asteroids:
		print("Despawn; child_count: %s" % $Asteroids.get_child_count())
		print("Children: %s" % $Asteroids.get_children())
		var player_position = %Player.global_position
		var furthest_asteroid = null
		var max_distance = -1.0
		
		# Find the furthest asteroid
		for asteroid in $Asteroids.get_children():
			var distance = asteroid.global_position.distance_to(player_position)
			if distance > max_distance:
				max_distance = distance
				furthest_asteroid = asteroid
		
		# De-spawn the furthest asteroid
		if furthest_asteroid:
			furthest_asteroid.explode()
	
	var asteroid_scene = preload("res://scenes/asteroid.tscn")
	var asteroid = asteroid_scene.instantiate()
	asteroid.visible = false
	asteroid.process_mode = Node.PROCESS_MODE_DISABLED	

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

	asteroid.position = spawn_pos
	asteroid.global_position = spawn_pos
	$Asteroids.add_child(asteroid)
	asteroid.process_mode = Node.PROCESS_MODE_INHERIT
	asteroid.visible = true
