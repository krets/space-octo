extends CharacterBody2D

var angular_velocity : float = 2.0  
var initial_velocity : Vector2 = Vector2(10, 3) 
var bodies : Array = []

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
	bodies.erase(body)
	if len(bodies) == 0:
		%Timer.stop()
