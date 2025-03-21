extends Node2D

@export var star_count = 1000  # Number of stars
var viewport_size: Vector2
var stars = []
@onready var player = $"/root/Game/Player"
@export var random_seed = 1234
@export var star_color = Color(1, 1, 1)
@export var max_star_size = 2.0
@export var max_depth = 5.0
@export var mult = 1
@export var static_star_ratio = 0.15 # Percentage of stars that stay on the player's plane

class Star:
	var pos: Vector2
	var depth: float
	var size: float
	var color: Color
	var is_static: bool # Whether this star moves exactly with the player

func _ready():
	viewport_size = get_viewport_rect().size
	seed(hash(random_seed))
	
	for i in star_count:
		var star = Star.new()
		star.pos = Vector2(
			randf() * viewport_size.x,
			randf() * viewport_size.y
		)
		
		# Some stars stay at depth 1.0 (same as the player)
		if randf() < static_star_ratio:
			star.depth = 1.0
			star.is_static = true
		else:
			star.depth = 1.0 + randf() * (max_depth - 1.0)
			star.is_static = false
		
		star.size = max_star_size * (1.0 / star.depth)
		var alpha = randf() * 0.5 + 0.5
		star.color = Color(star_color, alpha)
		stars.append(star)

func _process(delta):
	queue_redraw()
	
	var player_velocity = player.velocity
	var actual_movement = player.get_real_velocity() # Get actual movement after physics
	
	if actual_movement.length() > 0:
		for star in stars:
			if star.is_static:
				# Move at exactly the player's speed
				star.pos.x -= player_velocity.x * delta
				star.pos.y -= player_velocity.y * delta
			else:
				# Parallax movement
				star.pos.x -= (player_velocity.x * delta * (1.0 / star.depth) * mult)
				star.pos.y -= (player_velocity.y * delta * (1.0 / star.depth) * mult)
			
			# Wrap stars around the screen
			if star.pos.x < (0 - star.size):
				star.pos.x = viewport_size.x + star.size
			elif star.pos.x > viewport_size.x + star.size:
				star.pos.x = 0 - star.size
				
			if star.pos.y < 0 - star.size:
				star.pos.y = viewport_size.y + star.size
			elif star.pos.y > viewport_size.y + star.size:
				star.pos.y = 0 - star.size

func _draw():
	for star in stars:
		draw_circle(star.pos, star.size, star.color)
