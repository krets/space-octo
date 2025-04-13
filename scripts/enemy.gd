extends CharacterBody2D

@export var thrust_speed : float = 300
@export var brake_speed : float = 300
@export var turn_rate : float = 3.0
@export var max_speed : float = 600

@export var engagement_range: float = 800
@export var retreat_threshold: float = 0.3  # Health % to start fleeing
@export var fire_rate: float = 0.5  # Seconds between shots
@export var orbit_distance: float = 600  # Distance at which AI prefers to orbit
@export var orbit_strength: float = 0.5  # Strength of orbiting force
@export var bullet_scene: PackedScene  # Scene to instantiate for enemy bullets

var health: float = 100
var target: Node2D = null
var time_since_last_shot: float = 0.0
var fleeing: bool = false

# AI aim skill variables
var aim_jitter: float = 0.0  # Inaccuracy factor (radians)
var aim_prediction_skill: float = 0.0  # 0.0 = no lead, 1.0 = perfect prediction

@onready var player = get_tree().get_first_node_in_group("player")

func _ready():
	target = player
	add_to_group("enemy_ai")

	# Randomize aim skill per enemy instance
	aim_jitter = randf_range(0.01, 0.15)  # Higher = worse aim
	aim_prediction_skill = randf_range(0.4, 1.0)  # Higher = better leading

func _physics_process(delta: float) -> void:
	if target == null:
		return

	var to_target = (target.global_position - global_position)
	var distance = to_target.length()
	var predicted_pos = predict_player_position(distance)
	var target_angle = (predicted_pos - global_position).angle()
	var angle_diff = wrapf(target_angle - rotation, -PI, PI)

	if health <= retreat_threshold * 100:
		fleeing = true
	else:
		fleeing = false

	# --- ROTATION ---
	if fleeing:
		if angle_diff > 0:
			rotation -= turn_rate * delta
		else:
			rotation += turn_rate * delta
	else:
		if angle_diff > 0:
			rotation += turn_rate * delta
		else:
			rotation -= turn_rate * delta

	# --- THRUSTING WITH ORBIT + AVOIDANCE ---
	var thrust = Vector2.ZERO
	if fleeing:
		thrust = -Vector2(cos(rotation), sin(rotation)) * thrust_speed
	else:
		var forward = Vector2(cos(rotation), sin(rotation))
		thrust = forward * thrust_speed

		# Add orbital movement when within orbit distance
		if distance < orbit_distance:
			var orbit_dir = to_target.orthogonal().normalized()
			thrust += orbit_dir * (thrust_speed * orbit_strength)

	# Add avoidance steering
	thrust += avoid_other_enemies() * thrust_speed

	velocity += thrust * delta
	velocity = velocity.limit_length(max_speed)

	move_and_slide()

	# --- FIRING ---
	time_since_last_shot += delta  # Always count up

	if not fleeing and distance < engagement_range and abs(angle_diff) < 0.3:
		if time_since_last_shot >= fire_rate:
			fire_at(predicted_pos)
			time_since_last_shot = 0.0


func avoid_other_enemies() -> Vector2:
	var repulsion = Vector2.ZERO
	var separation_radius = 100.0
	for other in get_tree().get_nodes_in_group("enemy_ai"):
		if other == self:
			continue
		var distance = global_position.distance_to(other.global_position)
		if distance < separation_radius:
			var away = (global_position - other.global_position).normalized()
			repulsion += away * (1.0 - (distance / separation_radius))
	return repulsion.normalized()

func predict_player_position(distance_to_target: float) -> Vector2:
	if not target.has_method("get_velocity"):
		return target.global_position

	var player_velocity = target.get_velocity()
	var lead_time = (distance_to_target / max_speed) * aim_prediction_skill
	var predicted_position = target.global_position + player_velocity * lead_time

	# Add imperfect aim offset (jitter)
	var jitter_angle = randf_range(-aim_jitter, aim_jitter)
	return predicted_position.rotated(jitter_angle)

func fire_at(position: Vector2):
	if bullet_scene == null:
		return

	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.global_position = global_position

	var direction = (position - global_position).normalized()
	bullet.look_at(position)
	bullet.direction = direction

func take_damage(amount: float, attacker: Node2D) -> void:
	health -= amount
	if health <= 0:
		queue_free()
	else:
		target = attacker
