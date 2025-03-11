extends CharacterBody2D

@export var stats : Resource

@onready var healthbar_parent = $HealthBarParent
@onready var healthbar = $HealthBarParent/HealthBar

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
	
	healthbar_parent.global_rotation = 0.0
	healthbar.rotation = 0 
	move_and_slide()


func take_damage(damage : float) -> void:
	stats.health -= damage
	healthbar.health = stats.health
	print("Taking damage: " + str(damage))
	if stats.health <= 0:
		print("You dead now.")
		get_tree().change_scene_to_file("res://scenes/game_over.tscn")
	%DamageAnimation.play("damage_taken")
