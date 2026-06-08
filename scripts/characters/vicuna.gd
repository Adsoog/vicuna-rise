extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite

var knife_scene = preload("res://Scenes/Weapons/Knife.tscn")

var speed = 80.0
var last_direction = "down"

func _physics_process(delta):
	get_input()
	move_and_slide()

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	
	if input_direction == Vector2.ZERO:
		velocity = Vector2.ZERO
		update_animation("idle")
		return 
	
	if abs(input_direction.x) > abs(input_direction.y):
		if input_direction.x > 0:
			last_direction = "right"
		else:
			last_direction = "left"
	else:
		if input_direction.y > 0:
			last_direction = "down"
		else:
			last_direction = "up"
	
	update_animation("walk")
	velocity = input_direction * speed

func update_animation(state):
	animated_sprite.play(state + "_" + last_direction)

func _on_attack_timer_timeout() -> void:
	var target = get_closest_enemy()
	if target == null:
		return

	var knife = knife_scene.instantiate()
	var target_direction = (target.global_position - global_position).normalized()
	
	knife.set("direction", target_direction)
	
	get_parent().add_child(knife)
	knife.global_position = global_position
	
func get_closest_enemy():
	var enemies = get_tree().get_nodes_in_group("enemy")
	if enemies.size() == 0:
		return null

	var closest = enemies[0]
	var closest_distance = global_position.distance_to(closest.global_position)

	for enemy in enemies:
		var distance = global_position.distance_to(enemy.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest = enemy

	return closest
