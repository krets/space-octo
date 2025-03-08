extends Area2D

func _ready():
	self.connect("body_entered", _on_body_entered)
	self.connect("body_exited", _on_body_exited)
	

func _on_body_entered(body):
	var player = $"/root/Game/Player"
	
	if body != player:
		print("Body entered: ", body.name)

func _on_body_exited(body):
	print("Body exited: ", body.name)
