extends Area2D

var stat_name : String
var color : Color
var value : float = 1.0

func _ready() -> void:
	if not stat_name:
		var keys = PickupStats.stat_names.keys()
		stat_name = keys[randi() % keys.size()]
		color = PickupStats.get_color(stat_name)
		value = PickupStats.stat_names[stat_name]
	modulate = color
	$AudioStreamPlayer2D.pitch_scale = randf_range(0.95, 1.05)


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("do_pickup"):
		body.do_pickup(stat_name, value)
		$AnimationPlayer.play("pickup")
	else:
		print("Pickup huh?: %s" % body)
