extends Control

var player
@onready var colors = ColorNames.new()

func _ready() -> void:
	player = %Player
	#var pickup = preload("res://scenes/pickup.tscn")
	#for color in colors.all_colors:
		##var label = PanelContainer.new()
		#var instance = pickup.instantiate()
		#instance.modulate = color
		##label.add_child(instance)
		#$GridContainer.add_child(instance)
		#var value = Label.new()
		#value.text = "0"
		#$GridContainer.add_child(Label.new())
	$GridContainer/OrangeLabel["theme_override_colors/font_color"] = colors.orange
	$GridContainer/YellowLabel["theme_override_colors/font_color"] = colors.yellow
	$GridContainer/BlueLabel["theme_override_colors/font_color"] = colors.blue


func _process(delta: float) -> void:
	var x_pos = 0
	var y_pos = 0
	var points_orange = 0
	var points_blue = 0
	var points_yellow = 0
	if player:
		x_pos = int(player.global_position.x / 100)
		y_pos = int(player.global_position.y / 100)
		points_orange = player.stats.points_orange
		points_blue = player.stats.points_blue
		points_yellow = player.stats.points_yellow
	$GridContainer/PosValue.text = "(%s, %s)" % [x_pos, y_pos]
	$GridContainer/OrangeValue.text = str(points_orange)
	$GridContainer/BlueValue.text = str(points_blue)
	$GridContainer/YellowValue.text = str(points_yellow)
