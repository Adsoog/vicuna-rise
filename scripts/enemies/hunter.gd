extends CharacterBody2D

var player
var speed = 85.0

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if player == null:
		return

	var direction = (player.global_position - global_position).normalized()

	velocity = direction * speed
	move_and_slide()
