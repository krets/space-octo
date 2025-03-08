extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/ScanButton.connect("pressed", _on_ScanButton_pressed)
	$VBoxContainer/HailButton.connect("pressed", _on_HailButton_pressed)
	$VBoxContainer/MineButton.connect("pressed", _on_MineButton_pressed)

func _on_ScanButton_pressed():
	# Implement scan logic here
	print("Scanning...")

func _on_HailButton_pressed():
	# Implement hail logic here
	print("Hailing...")

func _on_MineButton_pressed():
	# Implement mine logic here
	print("Mining...")
