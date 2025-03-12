extends CharacterBody2D

@export var stats : Resource

@onready var healthbar_parent = $HealthBarParent
@onready var healthbar = $HealthBarParent/HealthBar
@onready var projectile = preload("res://scenes/projectile.tscn")
@onready var default_modulate = $ShipPolygon.modulate
@onready var main = 	get_tree().get_root().get_node("Game")
@onready var color_names = ColorNames.new()
func _ready() -> void:
	
	if not stats:
		print("Fuck; no stats")
	else:
		healthbar.init_health(stats.health)

func _physics_process(delta: float) -> void:

	if Input.is_action_pressed("turn_left"):
		rotation -= stats.turn_rate * delta
	elif Input.is_action_pressed("turn_right"):
		rotation += stats.turn_rate * delta
	
	if Input.is_action_pressed("thrust"):
		var thrust = Vector2(cos(rotation), sin(rotation)) * stats.thrust_speed
		velocity += thrust * delta
		
		velocity = velocity.limit_length(stats.max_speed)
	
	if Input.is_action_pressed("brake"):
		velocity = velocity.move_toward(Vector2.ZERO, stats.brake_speed * delta)
	
	if Input.is_action_pressed("shoot"):
		shoot()
	
	healthbar_parent.global_rotation = 0.0
	healthbar.rotation = 0 
	move_and_slide()


func do_pickup(color: Color) -> void:
	if color == color_names.orange:
		stats.points_orange += 1
	elif color == color_names.yellow:
		stats.points_yellow += 1
	elif color == color_names.blue:
		stats.points_blue += 1
	else:
		print("Unknown pickup: %s" % color)


func take_damage(damage : float) -> void:
	stats.health -= damage
	healthbar.health = stats.health

	if stats.health <= 0:
		print("You dead now.")
		get_tree().change_scene_to_file("res://scenes/game_over.tscn")
	%DamageAnimation.play("damage_taken")
	$ShipPolygon/DamageAnimTimer.start()

func clear_damage():
	%DamageAnimation.stop()
	$ShipPolygon.modulate = default_modulate

func shoot():
	if not $WeaponCooldown.is_stopped():
		return

	$WeaponCooldown.wait_time = stats.weapon_cooldown
	$WeaponCooldown.start()
	var instance = projectile.instantiate()
	
	instance.dir = rotation + PI/2
	instance.spawn_position = global_position
	instance.spawn_rotation = global_rotation
	instance.damage = stats.weapon_damage
	main.add_child(instance)


func _on_damage_anim_timer_timeout() -> void:
	clear_damage()
