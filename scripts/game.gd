extends Node2D

func _ready() -> void:
	var size = get_viewport().size
	$CanvasLayer/CanvasLayer/ColorRect.size = size
	print(ColorPalette.new().colors)
