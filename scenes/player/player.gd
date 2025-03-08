extends CharacterBody2D

@export var thrust_speed: float = 100
@export var brake_speed: float = 100
@export var rotation_speed: float = 5.0
@export var max_speed: float = 600 

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("turn_left"):
		rotation -= rotation_speed * delta
	elif Input.is_action_pressed("turn_right"):
		rotation += rotation_speed * delta
	
	if Input.is_action_pressed("thrust"):
		var thrust = Vector2(cos(rotation), sin(rotation)) * thrust_speed
		velocity += thrust * delta
		
		velocity = velocity.limit_length(max_speed)
	
	if Input.is_action_pressed("brake"):
		velocity = velocity.move_toward(Vector2.ZERO, brake_speed * delta)
	
	move_and_slide()

	# Rotate the Arrow towards the world origin, independent of player rotation
	var direction_to_origin = (Vector2.ZERO - position).normalized()
	$Arrow.rotation = direction_to_origin.angle() - rotation
