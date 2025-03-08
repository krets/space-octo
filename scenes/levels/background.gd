extends ColorRect

func _ready():
	var viewport_size = get_viewport().size
	size = viewport_size * 1.1
	position = (viewport_size * 0.5) - (size * 0.5)
