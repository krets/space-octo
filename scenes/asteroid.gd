extends CharacterBody2D

@export var stats : Resource = preload("res://resources/asteroid.tres")

var angular_velocity : float = randf_range(-4.0, 4.0)  # Random value between 1.0 and 5.0
var initial_velocity : Vector2 = Vector2(randf_range(1, 200), randf_range(1, 200)) 
var bodies : Array = []

var hit_damage : float = 10.0

func _ready() -> void:
	velocity = initial_velocity

func _physics_process(delta: float) -> void:
	move_and_slide()
	rotation += angular_velocity * delta

func _on_area_2d_body_entered(body: Node2D) -> void:
	print("Entered Damage Area: " + str(body))
	bodies.append(body)
	if %Timer.is_stopped():
		%Timer.start()

func _on_timer_timeout() -> void:
	for body in bodies:
		if body.has_method("take_damage"):
			body.take_damage(hit_damage)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.has_method("clear_damage"):
		body.clear_damage()
	bodies.erase(body)
	if len(bodies) == 0 and %Timer:
		%Timer.stop()

func take_damage(damage : float) -> void:
	stats.health -= damage
	if stats.health <= 0:
		spawn_pickups()
		explode()
		
func spawn_pickups():
	var pickup_scene = preload("res://scenes/pickup.tscn")
	var instance = pickup_scene.instantiate()
	instance.global_position = global_position
	get_parent().add_child(instance)

func explode():
	var debris_scene = preload("res://scenes/debris.tscn")
	var number_of_debris = 10
	var explosion_velocity = 1200
	queue_free()

	for i in range(number_of_debris):
		var debris_instance = debris_scene.instantiate()
		var random_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		debris_instance.position = global_position 
		debris_instance.initial_velocity  = random_direction * explosion_velocity
		get_parent().add_child(debris_instance)

func _on_death_timer_timeout() -> void:
	var rect = get_viewport_rect()
	if not rect.has_point(global_position):
		explode()
