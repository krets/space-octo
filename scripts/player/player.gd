extends CharacterBody2D

@export var stats : Resource


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
		#$CollisionShape2D/ShieldDisplay.self_modulate(Color.TRANSPARENT)
	elif stats.health <= stats.shield_grow_threshold:
		print("fading shield display")
		$CollisionShape2D.shape.radius = stats.shield_size_min
		var shield_color = Color(PickupStats.get_color("health"))
		
		var max_threshold = stats.shield_grow_threshold - stats.shield_display_min
		var current_value = stats.health - stats.shield_display_min
		var alpha = current_value / max_threshold
		shield_color.a = alpha
		display.scale.x = 1.0 
		display.scale.y = 1.0
		#$CollisionShape2D/ShieldDisplay.self_modulate(shield_color)
	else:
		var denominator = (stats.max_health - stats.shield_grow_threshold)
		if denominator != 0:
			var grow_factor = (stats.health - stats.shield_grow_threshold) / denominator
			var shield_size = grow_factor * (stats.shield_grow_size - stats.shield_size_min) + stats.shield_size_min
			print("Growing shield %s : %s" % [grow_factor, shield_size])
			$CollisionShape2D.shape.radius = shield_size
			display.scale.x = 1.0 + grow_factor
			display.scale.y = 1.0 + grow_factor
		else:
			print("Warning: Denominator is zero!")
			print("Initial values:")
			print("max_health: ", stats.max_health)
			print("health: ", stats.health)
			print("shield_grow_threshold: ", stats.shield_grow_threshold)
			print("shield_grow_size: ", stats.shield_grow_size)
			print("shield_size_min: ", stats.shield_size_min)

func do_pickup(stat_name: String, value: float) -> void:
	stats.set(stat_name, value + stats.get(stat_name))
	draw_shield()


func take_damage(damage : float) -> void:
	stats.health -= damage
	print("player received: %s damage" % damage)
	if stats.health <= 0.0:
		print("You dead now.")
		%DamageAnimation.play("death")
		await %DamageAnimation.animation_finished
		get_tree().change_scene_to_file("res://scenes/game_over.tscn")
		return
	%DamageAnimation.play("damage_taken")
	$ShipPolygon/DamageAnimTimer.start()
	draw_shield()

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
	instance.velocity = velocity
	main.add_child(instance)


func _on_damage_anim_timer_timeout() -> void:
	clear_damage()

		
