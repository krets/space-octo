extends Object

class_name ColorNames

static var orange = Color(0.9, 0.6, 0.0)
static var yellow = Color(0.95, 0.9, 0.25)
static var blue = Color(0.0, 0.45, 0.7)

static var all_colors : Array[Color] = [orange, yellow, blue]


func get_color():
	return all_colors[randi() % all_colors.size()]
