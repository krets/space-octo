extends Node2D

@export var speed: float = 800
var direction: Vector2 = Vector2.ZERO

func _process(delta):
	if direction != Vector2.ZERO:
		position += direction * speed * delta

	# Optional: cleanup
	if not get_viewport_rect().has_point(global_position):
		queue_free()
