extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D

var xp_scene = preload("res://Scenes/Items/XPItem.tscn")

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
	
	if velocity.length() > 0:
		update_direction_string(direction)
		update_animation("run")
	else:
		update_animation("idle")

func update_direction_string(dir: Vector2):
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
	animated_sprite.play(state + "_" + last_direction)

func die():
	var xp = xp_scene.instantiate()
	get_parent().add_child(xp)
	xp.global_position = global_position
	queue_free()
