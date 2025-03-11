extends Area2D

@export var color : Color
@onready var color_names = ColorNames.new()
var player

func _ready() -> void:
	if not color:
		color = color_names.get_color()
	modulate = color


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("do_pickup"):
		body.do_pickup(color)
	else:
		print("Pickup huh?: %s" % body)
	queue_free()
