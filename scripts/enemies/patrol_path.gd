extends Path2D

@onready var path_follow = $PathFollow2D
var speed = 120.0

func _process(delta):
	if path_follow:
		path_follow.progress += speed * delta
