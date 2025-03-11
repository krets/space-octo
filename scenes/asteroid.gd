extends CharacterBody2D

@export var stats : Resource

var angular_velocity : float = 2.0  
var initial_velocity : Vector2 = Vector2(10, 3) 
var bodies : Array = []
@onready var main = 	get_tree().get_root().get_node("Game")

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
			body.take_damage(2.0)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.has_method("clear_damage"):
		body.clear_damage()
	bodies.erase(body)
	if len(bodies) == 0:
		%Timer.stop()

func take_damage(damage : float) -> void:
	stats.health -= damage
	if stats.health <= 0:
		explode()


func explode():
	var debris_scene = preload("res://scenes/debris.tscn")
	var number_of_debris = 10
	var explosion_velocity = 1000.0  # Adjust as needed
	queue_free()

	for i in range(number_of_debris):
		var debris_instance = debris_scene.instantiate()
		var random_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		debris_instance.position = global_position 
		debris_instance.initial_velocity  = random_direction * explosion_velocity
		main.add_child(debris_instance)
