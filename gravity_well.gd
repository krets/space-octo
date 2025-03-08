extends Node2D

@export var strength: float = 1200000.0 
@export var falloff_distance: float = 0.0

var self_planet

func _ready() -> void:
	self_planet = $".."
	var collision_shape = $CollisionShape2D
	self.connect("body_entered", _on_body_entered)
	self.connect("body_exited", _on_body_exited)
	falloff_distance = collision_shape.shape.get_radius()
	print(falloff_distance)

func _on_body_entered(body):
	if body == self_planet:
		return
	print("Gravity Well entered: ", body.name)
	
	if body.has_method("add_gravity_well"):
		body.add_gravity_well(self)

func _on_body_exited(body):
	print("Gravity Well exited: ", body.name)
	
	if body.has_method("remove_gravity_well"):
		body.remove_gravity_well(self)

func get_falloff_distance() -> float:
	var collision_shape = $CollisionShape2D
	if collision_shape.shape:
		return collision_shape.shape.get_radius()
	return 0.0
