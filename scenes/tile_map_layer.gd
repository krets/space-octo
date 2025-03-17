extends TileMapLayer

var current_viewport_center := Vector2.ZERO
var viewport_size := Vector2.ZERO
var collision_padding = 100
var rows = 5
var cols = 5
var check_areas := {}

func _ready():
	print("TileMapLayer Ready.")
	viewport_size = get_viewport_rect().size
	update_current_viewport()
	build_viewport_area()
	setup_trigger_areas()

func setup_trigger_areas():
	var updown_size = Vector2i(viewport_size.x + collision_padding*2, collision_padding)
	var left_right_size = Vector2(collision_padding, viewport_size.y + collision_padding*2)

	var boxes = {
		'up': updown_size, 
		'down': updown_size, 
		'left': left_right_size, 
		'right': left_right_size
	}

	for key in boxes.keys():
		var area = Area2D.new()
		var collision = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		shape.extents = boxes[key]
		collision.shape = shape
		area.body_entered.connect(_on_area_entered)
		check_areas[key] = area
		area.add_child(collision)
		add_child(area)
	reposition_trigger_areas()

	
func reposition_trigger_areas():
	print("viewport move")
	var viewport = get_viewport().get_visible_rect()
	var viewport_position = get_canvas_transform().affine_inverse().origin
	for key in check_areas.keys():
		var area = check_areas[key]
		if key == 'up':
			area.position.x = viewport_position.x - collision_padding
			area.position.y = viewport_position.y - collision_padding
		elif key == 'down':
			area.position.x = viewport_position.x - collision_padding
			area.position.y = viewport_position.y + viewport.size.y
		elif key == 'left':
			area.position.x = viewport_position.x - collision_padding
			area.position.y = viewport_position.y - collision_padding
		elif key == 'right':
			area.position.x = viewport_position.x + viewport.size.x
			area.position.y = viewport_position.y - collision_padding

func _on_area_entered(_body):
	update_current_viewport()
	build_viewport_area()
	reposition_trigger_areas()


func update_current_viewport() -> void:
	var transform = get_canvas_transform().affine_inverse()
	current_viewport_center = transform * (viewport_size / 2)

func build_viewport_area() -> void:
	var transform = get_canvas_transform().affine_inverse()
	
	var center_pos = local_to_map(current_viewport_center)
	var half_width = local_to_map(viewport_size).x
	var half_height = local_to_map(viewport_size).y
	
	var start_pos = center_pos - Vector2i(half_width * 2, half_height * 2)
	var end_pos = center_pos + Vector2i(half_width * 2, half_height * 2)
	
	# Clear cells outside our expanded area
	var cells = get_used_cells()
	for cell in cells:
		if (cell.x < start_pos.x - (cols + 1) or cell.x > end_pos.x + (cols +1) or
		   cell.y < start_pos.y - (rows + 1)  or cell.y > end_pos.y + (rows + 1)):
			erase_cell(cell)
	
	# Fill all cells in the expanded area with the 4x4 pattern
	for x in range(start_pos.x, end_pos.x + 1):
		for y in range(start_pos.y, end_pos.y + 1):
			var pos = Vector2i(x, y)
			if get_cell_source_id(pos) == -1:
				var pattern_x = posmod(x, cols)
				var pattern_y = posmod(y, rows)
				
				var atlas_coords = Vector2i(0, 0)
				
				if pattern_x == 0 and pattern_y == 0:
					atlas_coords = Vector2i(0, 0)
				elif pattern_x > 0 and pattern_y == 0:
					atlas_coords = Vector2i(1, 0)
				elif pattern_x == 0 and pattern_y > 0:
					atlas_coords = Vector2i(0, 1)
				else:
					atlas_coords = Vector2i(1, 1)
				
				set_cell(pos, 0, atlas_coords)
