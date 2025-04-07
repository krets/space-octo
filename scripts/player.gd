extends CharacterBody2D

@onready var default_modulate = $ShipPolygon.modulate

@export var thrust_speed : float = 400
@export var brake_speed : float = 400
@export var turn_rate : float = 3.0
@export var max_speed : float = 600

# Dash parameters
@export var dash_speed : float = 1200
@export var dash_duration : float = 0.2
@export var dash_cooldown : float = 1.0

# Power dash parameters
@export var power_dash_speed : float = 4000
@export var power_dash_duration : float = 0.5
@export var power_dash_cooldown : float = 0.1
@export var power_dash_charge_time : float = 1

# Dash state
var is_dashing = false
var dash_time = 0.0
var dash_cooldown_timer = 0.0
var dash_direction = Vector2.ZERO

# Charging state
var is_charging = false
var charge_timer = 0.0


func _physics_process(delta: float) -> void:
	# Handle rotation
	if Input.is_action_pressed("turn_left"):
		rotation -= turn_rate * delta
	elif Input.is_action_pressed("turn_right"):
		rotation += turn_rate * delta

	# Handle dash button press (only if thrusting)
	if Input.is_action_pressed("dash") and Input.is_action_pressed("thrust") and dash_cooldown_timer <= 0.0 and not is_dashing:
		if not is_charging:
			is_charging = true
			charge_timer = 0.0
		charge_timer += delta

	# Handle dash button release
	if Input.is_action_just_released("dash") and is_charging and dash_cooldown_timer <= 0.0:
		is_charging = false

		# Only perform dash if thrusting
		if Input.is_action_pressed("thrust"):
			dash_direction = Vector2(cos(rotation), sin(rotation))
			
			if charge_timer >= power_dash_charge_time:
				# Power dash
				is_dashing = true
				dash_time = power_dash_duration
				dash_cooldown_timer = power_dash_cooldown
				velocity = dash_direction * power_dash_speed
			else:
				# Normal dash
				is_dashing = true
				dash_time = dash_duration
				dash_cooldown_timer = dash_cooldown
				velocity = dash_direction * dash_speed

	# Handle dash timing
	if is_dashing:
		# Cancel dash early if thrust is released
		if not Input.is_action_pressed("thrust"):
			is_dashing = false
		else:
			dash_time -= delta
			if dash_time <= 0.0:
				is_dashing = false
	else:
		# Apply thrust and brake normally
		if Input.is_action_pressed("thrust"):
			var thrust = Vector2(cos(rotation), sin(rotation)) * thrust_speed
			velocity += thrust * delta
			velocity = velocity.limit_length(max_speed)

		if Input.is_action_pressed("brake"):
			velocity = velocity.move_toward(Vector2.ZERO, brake_speed * delta)

	# Cooldown countdown
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta

	move_and_slide()
