extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite
@onready var pivote_arma: Node2D = $PivoteArma
var HachaLanzada = preload("res://hacha_lanzada.tscn")

var speed = 100.0

func _physics_process(delta):
	get_input()
	move_and_slide()
	update_animation()
	apuntar()
	
	if Input.is_action_just_pressed("ui_accept"):
		lanzar_hacha_spread(3, 15.0)

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed
	
	if input_direction.x != 0:
		animated_sprite.flip_h = input_direction.x < 0

func update_animation():
	if velocity.length() > 0:
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")

func apuntar():
	var mouse_pos = get_global_mouse_position()
	var angulo = global_position.angle_to_point(mouse_pos)
	pivote_arma.rotation = angulo

func lanzar_hacha_spread(cantidad, separacion_grados):
	var angulo_base = pivote_arma.rotation
	var delta_theta = deg_to_rad(separacion_grados)
	var offset_inicial = -delta_theta * floor(cantidad / 2.0)
	
	for i in range(cantidad):
		var angulo_final = angulo_base + offset_inicial + (i * delta_theta)
		var nueva_hacha = HachaLanzada.instantiate()
		get_tree().current_scene.add_child(nueva_hacha)
		nueva_hacha.disparar(pivote_arma.global_position, angulo_final)
