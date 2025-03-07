extends Polygon2D

@onready var mirrored_polygon = $CopiedShape

func _ready():
	update_mirrored_polygon()

func update_mirrored_polygon():
	var original_points = polygon
	var mirrored_points = []
	
	for point in original_points:
		mirrored_points.append(Vector2(point.x, -point.y))
	
	mirrored_polygon.polygon = mirrored_points

func _process(delta):
	update_mirrored_polygon()
