extends Node2D

@export var star_count = 1000
@export var minor_grid_size = 100
@export var major_grid_size = 500
@export var minor_grid_color = Color(0.3, 0.3, 0.3, 0.5)
@export var major_grid_color = Color(0.4, 0.4, 0.4, 0.7)
var viewport_size: Vector2
var stars = []
@onready var player = $"/root/Game/Player"
@export var random_seed = 1234
@export var star_color = Color(1, 1, 1)
@export var max_star_size = 3.0
@export var max_depth = 5.0
@export var mult = 0.1
var camera_pos = Vector2.ZERO

class Star:
		var pos: Vector2
		var depth: float
		var size: float
		var color: Color

func _ready():
	viewport_size = get_viewport_rect().size
	seed(hash(random_seed))

	for i in star_count:
		var star = Star.new()
		star.pos = Vector2(
			randf() * viewport_size.x,
			randf() * viewport_size.y
		)
		star.depth = 1.0 + randf() * (max_depth - 1.0)
		star.size = max_star_size * (1.0 / star.depth)
		var alpha = randf() * 0.5 + 0.5
		star.color = Color(star_color, alpha)
		stars.append(star)

func _process(delta):
	queue_redraw()
	camera_pos = player.global_position
	
	var player_velocity = player.velocity
	var actual_movement = player.get_real_velocity()

	if actual_movement.length() > 0:
		for star in stars:
			star.pos.x -= (player_velocity.x * delta * (1.0 / star.depth) * mult)
			star.pos.y -= (player_velocity.y * delta * (1.0 / star.depth) * mult)

			if star.pos.x < (0 - star.size):
				star.pos.x = viewport_size.x + star.size
			elif star.pos.x > viewport_size.x + star.size:
				star.pos.x = 0 - star.size

			if star.pos.y < 0 - star.size:
				star.pos.y = viewport_size.y + star.size
			elif star.pos.y > viewport_size.y + star.size:
				star.pos.y = 0 - star.size

func _draw():
	var screen_offset = get_viewport_transform().origin
	var start_x = floor((camera_pos.x - viewport_size.x/2) / minor_grid_size) * minor_grid_size
	var start_y = floor((camera_pos.y - viewport_size.y/2) / minor_grid_size) * minor_grid_size
	var end_x = ceil((camera_pos.x + viewport_size.x/2) / minor_grid_size) * minor_grid_size
	var end_y = ceil((camera_pos.y + viewport_size.y/2) / minor_grid_size) * minor_grid_size

	# Draw minor grid lines
	for x in range(start_x, end_x + minor_grid_size, minor_grid_size):
		var color = major_grid_color if int(x) % major_grid_size == 0 else minor_grid_color
		var start = Vector2(x, start_y) - camera_pos + viewport_size/2
		var end = Vector2(x, end_y) - camera_pos + viewport_size/2
		draw_line(start, end, color)

	for y in range(start_y, end_y + minor_grid_size, minor_grid_size):
		var color = major_grid_color if int(y) % major_grid_size == 0 else minor_grid_color
		var start = Vector2(start_x, y) - camera_pos + viewport_size/2
		var end = Vector2(end_x, y) - camera_pos + viewport_size/2
		draw_line(start, end, color)

	# Draw stars
	for star in stars:
		draw_circle(star.pos, star.size, star.color)
