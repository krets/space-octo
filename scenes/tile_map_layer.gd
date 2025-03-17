extends TileMapLayer

func _ready():
	update_visible_cells()

func _process(_delta):
	update_visible_cells()

func update_visible_cells() -> void:
	var viewport_size = get_viewport_rect().size
	var transform = get_canvas_transform().affine_inverse()
	
	# Convert viewport coordinates to tilemap coordinates
	var start_pos = local_to_map(transform * Vector2.ZERO)
	var end_pos = local_to_map(transform * viewport_size)
	
	# Add some padding to prevent visual gaps when moving
	start_pos -= Vector2i(2, 2)
	end_pos += Vector2i(2, 2)
	
	# Clear cells that are too far outside the viewport
	var cells = get_used_cells()
	for cell in cells:
		if (cell.x < start_pos.x - 5 or cell.x > end_pos.x + 5 or
		   cell.y < start_pos.y - 5 or cell.y > end_pos.y + 5):
			erase_cell(cell)
	
	# Fill all visible cells with the 4x4 pattern
	for x in range(start_pos.x, end_pos.x + 1):
		for y in range(start_pos.y, end_pos.y + 1):
			var pos = Vector2i(x, y)
			if get_cell_source_id(pos) == -1:  # Check if cell is empty
				var pattern_x = posmod(x, 4)  # Get position in 4x4 pattern (0-3)
				var pattern_y = posmod(y, 4)  # Get position in 4x4 pattern (0-3)
				
				var atlas_coords = Vector2i(0, 0)  # Default to first tile
				
				if pattern_x == 0 and pattern_y == 0:
					atlas_coords = Vector2i(0, 0)  # Top-left corner
				elif pattern_x > 0 and pattern_y == 0:
					atlas_coords = Vector2i(1, 0)  # Top row
				elif pattern_x == 0 and pattern_y > 0:
					atlas_coords = Vector2i(0, 1)  # Left column
				else:
					atlas_coords = Vector2i(1, 1)  # Everything else
				
				set_cell(pos, 0, atlas_coords)
