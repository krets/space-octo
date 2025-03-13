extends Resource

class_name PickupStats

static var palette : Resource = preload("res://resources/color_palette.tres")

# Must be <= number of colors in color_palette.tres
static var stat_names = {
	"speed": 25,
	"weapon_damage": 10,
	"health": 15,
}

static func get_stat_name(color: Color) -> String:
	for i in range(palette.colors.size()):
		if color == palette.colors[i]:
			return stat_names.keys()[i]  # Return the key (stat name)
	return ""
	
static func get_color(stat_name: String) -> Color:
	var keys = stat_names.keys()
	for i in range(keys.size()):
		if keys[i] == stat_name:
			return palette.colors[i]
	return Color.AQUA
