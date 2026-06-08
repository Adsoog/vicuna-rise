extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D # Cambia el nombre si en tu escena se llama diferente (ej. $AnimatedSprite)

var player
var speed = 75.0
var last_direction = "down"

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if player == null:
		return

	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()
	
	# Si se está moviendo, actualizamos la dirección visual
	if velocity.length() > 0:
		update_direction_string(direction)
		update_animation("run") # Si tus animaciones de correr se llaman "run_up", "run_down", etc.
	else:
		update_animation("idle") # Por si en algún momento se detiene

func update_direction_string(dir: Vector2):
	# Determinamos si el movimiento es más horizontal o vertical
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			last_direction = "right"
		else:
			last_direction = "left"
	else:
		if dir.y > 0:
			last_direction = "down"
		else:
			last_direction = "up"

func update_animation(state):
	# Esto combina "run" o "idle" con la dirección actual (ej. "run_up")
	animated_sprite.play(state + "_" + last_direction)
