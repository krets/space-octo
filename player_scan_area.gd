extends Area2D

var highlight_material = preload("res://highlight.gdshader")
var scannable_objects = [] # All objects in scan area
var current_selected_object = null
var current_index = -1

@export var default_highlight_color = Color(1.0, 1.0, 0.0, 1.0) # Yellow/default highlight
@export var selected_highlight_color = Color(0.0, 0.6, 1.0, 1.0) # Blue highlight

func _ready():
	self.connect("body_entered", _on_body_entered)
	self.connect("body_exited", _on_body_exited)

func _process(_delta):
	if Input.is_action_just_pressed("next_selection"):
		cycle_selection()

func cycle_selection():
	# Update previous selection to default highlight
	if current_selected_object != null:
		add_highlight(current_selected_object, default_highlight_color)
	
	# If we have objects to select from
	if scannable_objects.size() > 0:
		# If nothing is selected yet, start at -1
		if current_index == -1:
			current_index = 0
		else:
			# Increment index and wrap around
			current_index = (current_index + 1) % scannable_objects.size()
			
		current_selected_object = scannable_objects[current_index]
		add_highlight(current_selected_object, selected_highlight_color)
	else:
		current_index = -1
		current_selected_object = null

func add_highlight(body, color):
	if body.has_node("Sprite2D"):
		var sprite = body.get_node("Sprite2D")
		var material = ShaderMaterial.new()
		material.shader = highlight_material
		material.set_shader_parameter("highlight_color", color)
		sprite.material = material

func remove_highlight(body):
	if body.has_node("Sprite2D"):
		var sprite = body.get_node("Sprite2D")
		sprite.material = null

func _on_body_entered(body):
	var player = $"/root/Game/Player"
	
	if body != player:
		print("Body in scan area: ", body.name)
		# Add to scannable objects
		if not body in scannable_objects:
			scannable_objects.append(body)
			add_highlight(body, default_highlight_color)

func _on_body_exited(body):
	print("Body exited scan area: ", body.name)
	
	# Remove from scannable objects
	if body in scannable_objects:
		var index = scannable_objects.find(body)
		scannable_objects.erase(body)
		remove_highlight(body)
		
		# If the exiting object was selected
		if body == current_selected_object:
			current_selected_object = null
			current_index = -1
