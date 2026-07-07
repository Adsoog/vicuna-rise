extends Area2D

var speed = 145.0
var direction = Vector2.ZERO
var rotation_speed = 15.0 
var lifetime = 0.95

func _process(delta):
	position += direction * speed * delta
	rotation += rotation_speed * delta
	
	lifetime -= delta
	if lifetime <= 0:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		if body.has_method("die"):
			body.die()
		else:
			body.queue_free()
		queue_free()
