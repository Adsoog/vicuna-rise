extends Area2D

var speed = 300.0
var direction = Vector2.ZERO

func _process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		body.queue_free()
		queue_free()
