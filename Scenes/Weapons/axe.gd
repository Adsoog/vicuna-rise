extends Area2D

var speed_x = 0.0
var speed_y = -400.0
var axe_gravity = 900.0
var rotation_speed = 12.0


func _ready():
	speed_x = randf_range(-150.0, 150.0)


func _process(delta):
	speed_y += axe_gravity * delta
	
	position.x += speed_x * delta
	position.y += speed_y * delta
	
	rotation += rotation_speed * delta


func _on_body_entered(body):
	if body.is_in_group("enemy"):
		if body.has_method("die"):
			body.die()
		else:
			body.queue_free()
		queue_free()
