extends CharacterBody2D

@onready var default_modulate = $ShipPolygon.modulate
@export var thrust_speed : float = 100
@export var brake_speed : float = 50
@export var turn_rate : float = 3.0
@export var max_speed : float = 200


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("turn_left"):
		rotation -= turn_rate * delta
	elif Input.is_action_pressed("turn_right"):
		rotation += turn_rate * delta
	
	if Input.is_action_pressed("thrust"):
		var thrust = Vector2(cos(rotation), sin(rotation)) * thrust_speed
		velocity += thrust * delta
		velocity = velocity.limit_length(max_speed)
	
	if Input.is_action_pressed("brake"):
		velocity = velocity.move_toward(Vector2.ZERO, brake_speed * delta)

	move_and_slide()
