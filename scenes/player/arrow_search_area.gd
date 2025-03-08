extends Area2D

var arrow
func _ready() -> void:
	arrow = $"../Arrow"

func _process(delta):
	# Check for all overlapping bodies
	
	var overlapping_bodies = get_overlapping_bodies()
	if len(overlapping_bodies)>1:  # expecting 1 only for player
		arrow.visible = false
	else:
		arrow.visible = true
