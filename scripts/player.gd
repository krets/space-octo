extends CharacterBody2D

@export var stats : Resource
@export var invincible : bool = false

@onready var projectile = preload("res://scenes/projectile.tscn")
@onready var default_modulate = $ShipPolygon.modulate
@onready var main = 	get_tree().get_root().get_node("Game")
@onready var color_names = ColorNames.new()

@onready var colision_size : int = $CollisionShape2D.shape.radius
var trail_color : Color = Color(1,1,1,0.6)

var current_trail : MovementTrail

func _ready() -> void:
	draw_shield()

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("turn_left"):
		rotation -= stats.turn_rate * delta
	elif Input.is_action_pressed("turn_right"):
		rotation += stats.turn_rate * delta
	
	if Input.is_action_pressed("thrust"):
		var thrust = Vector2(cos(rotation), sin(rotation)) * stats.thrust_speed
		velocity += thrust * delta
		$MovementTrail.modulate = ColorNames.orange
		velocity = velocity.limit_length(stats.max_speed)
		$AnimationPlayer.play("thrusting")
	else:
		$MovementTrail.modulate = trail_color
	
	if Input.is_action_pressed("brake"):
		velocity = velocity.move_toward(Vector2.ZERO, stats.brake_speed * delta)
	
	if Input.is_action_pressed("shoot"):
		shoot()
	

	move_and_slide()

func draw_shield() -> void:
	var display = $CollisionShape2D/ShieldDisplay

	if stats.health < stats.shield_display_min:
		print("no shield display")
		$CollisionShape2D.shape.radius = stats.shield_size_empty
		$CollisionShape2D/ShieldDisplay.modulate = Color.TRANSPARENT

	elif stats.health <= stats.shield_grow_threshold:
		print("fading shield display")
		$CollisionShape2D.shape.radius = stats.shield_size_min
		var shield_color = Color(PickupStats.get_color("health"))
		
		var alpha = inverse_lerp(stats.shield_display_min, stats.shield_grow_threshold, stats.health)
		shield_color.a = alpha
		display.scale.x = 1.0 
		display.scale.y = 1.0
		$CollisionShape2D/ShieldDisplay.modulate = shield_color
	else:
		var grow_factor = inverse_lerp(stats.shield_grow_threshold, stats.max_health, stats.health)
		var shield_size = lerp(stats.shield_size_min, stats.shield_grow_size, grow_factor)
		print("Growing shield %s : %s" % [grow_factor, shield_size])
		$CollisionShape2D.shape.radius = shield_size / 2
		display.scale.x = 1.0 + grow_factor
		display.scale.y = 1.0 + grow_factor

func do_pickup(stat_name: String, value: float) -> void:
	var new_value = value + stats.get(stat_name)
	var max_value = stats.get("max_%s" % stat_name)

	if stat_name == "speed":
		# Calculate speed boost percentage (0 to 1)
		var speed_factor = new_value / stats.max_speed_boost
		speed_factor = clamp(speed_factor, 0.0, 1.0)
		
		# Adjust thrust and brake speeds
		stats.thrust_speed = lerp(stats.min_thrust_speed, stats.max_thrust_speed, speed_factor)
		stats.brake_speed = lerp(stats.min_brake_speed, stats.max_brake_speed, speed_factor)
		
		# Adjust weapon cooldown
		var before = stats.weapon_cooldown
		stats.weapon_cooldown = lerp(stats.min_weapon_cooldown, stats.max_weapon_cooldown, speed_factor)
		
		print("Weapon cooldown %s -> %s" % [before, stats.weapon_cooldown])
		# Store the speed value
		stats.speed = new_value
	else:
		# Handle other stats normally
		if max_value:
			new_value = min(max_value, new_value)
		stats.set(stat_name, new_value)

	draw_shield()

func take_damage(damage : float) -> void:
	
	stats.health -= damage
	stats.weapon_damage -= damage/2
	stats.weapon_damage = max(stats.min_weapon_damage, stats.weapon_damage)
	print("player received: %s damage" % damage)
	if stats.health <= 0.0:
		print("You dead now.")
		$AnimationPlayer.play("Death")

	%DamageAnimation.play("damage_taken")
	invincible = true
	$ShipPolygon/DamageAnimTimer.start()
	draw_shield()

func change_scene():
	var tree = get_tree()
	if not tree:
		print("Life is hard; the tree is null.")
	else:
		get_tree().change_scene_to_file("res://scenes/game_over.tscn")
	return

func clear_damage():
	%DamageAnimation.stop()
	$ShipPolygon.modulate = default_modulate
	invincible = false

func shoot():
	if not $WeaponCooldown.is_stopped():
		return
	$WeaponCooldown.wait_time = stats.weapon_cooldown
	$WeaponCooldown.start()
	var instance = projectile.instantiate()
	
	instance.dir = rotation + PI/2
	instance.spawn_position = $ProjectileExitPoint.global_position
	instance.spawn_rotation = global_rotation
	
	instance.damage = stats.weapon_damage
	instance.scale *= 1.0 + stats.weapon_damage/stats.max_weapon_damage
	instance.velocity = velocity
	main.add_child(instance)


func _on_damage_anim_timer_timeout() -> void:
	clear_damage()

		
