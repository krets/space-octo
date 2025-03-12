extends Node2D

@onready var parent = get_parent()
@export var trail_scale : float = 0.001

func _ready() -> void:
	scale.x = 1.0

func _process(delta: float) -> void:
	var velocity = parent.velocity
	var trail_x_size = velocity.length() * trail_scale
	scale.x = trail_x_size
	
	if velocity.length() > 0:
		look_at(global_position + velocity)
