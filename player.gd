extends CharacterBody2D

var thrust_speed: float = 600
var brake_speed: float = 300
var rotation_speed: float = 5.0
var max_speed: float = 400 

var active_gravity_wells: Array = []

func _physics_process(delta: float) -> void:
	apply_gravity(delta)

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

func add_gravity_well(gravity_well: Node2D) -> void:
	active_gravity_wells.append(gravity_well)

func remove_gravity_well(gravity_well: Node2D) -> void:
	active_gravity_wells.erase(gravity_well)

func apply_gravity(delta: float) -> void:
	for gravity_well in active_gravity_wells:
		var distance = global_position.distance_to(gravity_well.global_position)
		if distance < gravity_well.falloff_distance:
			var effect_strength = gravity_well.strength / (distance * distance)  # Inverse square law
			var gravity_direction = (gravity_well.global_position - global_position).normalized()
			velocity += gravity_direction * effect_strength * delta
