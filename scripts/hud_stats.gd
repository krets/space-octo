extends Control

var player
#@onready var colors = ColorNames.new()
@onready var palette : Resource = preload("res://resources/color_palette.tres")

var stat_labels = {}

func _ready() -> void:
	player = %Player
	
	for stat_name in PickupStats.stat_names.keys():
		var label = Label.new()
		label.text = "▇ %s" % stat_name
		label["theme_override_colors/font_color"] = PickupStats.get_color(stat_name)
		
		var value_label = Label.new()
		$GridContainer.add_child(label)
		$GridContainer.add_child(value_label)
		
		stat_labels[stat_name] = value_label

func _process(delta: float) -> void:
	var x_pos = 0
	var y_pos = 0
	var points_orange = 0
	var points_blue = 0
	var points_yellow = 0
	if player:
		x_pos = int(player.global_position.x / 100)
		y_pos = int(player.global_position.y / 100)

	$GridContainer/PosValue.text = "(%s, %s)" % [x_pos, y_pos]

	for stat_name in PickupStats.stat_names:
		if stat_labels.has(stat_name):
			stat_labels[stat_name].text = "%0.1f" % player.stats.get(stat_name)
