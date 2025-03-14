extends CharacterBody2D

@export var speed : float = 900
@export var lifetime : float = 3.0
@export var damage : float = 1.0

var dir : float
var spawn_position : Vector2
var spawn_rotation : float

func _ready() -> void:
	global_position = spawn_position
	global_rotation = spawn_rotation
	$Lifetime.wait_time = lifetime
	$Lifetime.start()
	velocity += Vector2(0, - speed).rotated(dir)
	$ShootSound.pitch_scale = randf_range(0.99, 1.01)
	$ShootSound.volume_db = randf_range(0.98, 1.02)
	$HitSound.pitch_scale = randf_range(0.99, 1.01)
	$HitSound.volume_db = randf_range(0.98, 1.02)
	$Oomph.volume_db = lerp(-30.0, -0.5, damage/200)
	print("Volume: %s" % $Oomph.volume_db)
	$AnimationPlayer.play("pewpew")
	
func _physics_process(delta: float) -> void:
	move_and_slide()

func _on_lifetime_timeout() -> void:
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
		$AnimationPlayer.play("hit")
	print("Hit Body: " + str(body))
