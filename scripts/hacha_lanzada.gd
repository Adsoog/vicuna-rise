extends Area2D

var speed = 400.0
var velocity_x = 0.0
var velocity_y = 0.0

func disparar(posicion_inicial, angulo):
	global_position = posicion_inicial
	rotation = angulo
	
	velocity_x = cos(angulo)
	velocity_y = sin(angulo)

func _physics_process(delta):
	global_position.x += velocity_x * speed * delta
	global_position.y += velocity_y * speed * delta
