extends CharacterBody2D

@export var speed : float = 800
@export var lifetime : float = 1.2
@export var damage : float = 1.0

var dir : float
var spawn_position : Vector2
var spawn_rotation : float

func _ready() -> void:
	global_position = spawn_position
	global_rotation = spawn_rotation
	$Lifetime.wait_time = lifetime
	$Lifetime.start()
	
func _physics_process(delta: float) -> void:
	velocity = Vector2(0, -speed).rotated(dir)
	move_and_slide()

func _on_lifetime_timeout() -> void:
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()
	print("Hit Body: " + str(body))
