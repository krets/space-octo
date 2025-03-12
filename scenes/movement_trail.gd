class_name MovementTrail
extends Line2D

const MAX_POINTS : int = 50
@onready var curve := Curve2D.new()


func _process(delta: float) -> void:
	print("curve point: %s" % get_parent().position)
	curve.add_point(get_parent().position)
	if curve.get_baked_points().size() > MAX_POINTS:
		curve.remove_point(0)
	points = curve.get_baked_points()
