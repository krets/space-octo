extends Control

var player

func _ready() -> void:
	player = %Player


func _process(delta: float) -> void:
	var x_pos = int(player.global_position.x / 100)
	var y_pos = int(player.global_position.y / 100)
	$GridContainer/PosValue.text = "%s, %s" % [x_pos, y_pos]
