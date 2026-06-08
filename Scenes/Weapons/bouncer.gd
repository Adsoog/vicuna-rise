extends Area2D

var speed = 250.0
var direction = Vector2.ZERO
var bounces_left = 4 
var rotation_speed = 8.0
var lifetime = 3.0

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
		
		bounces_left -= 1
		if bounces_left <= 0:
			queue_free()
		else:
			rebound_to_next_enemy(body)

func rebound_to_next_enemy(current_enemy):
	var enemies = get_tree().get_nodes_in_group("enemy")
	var next_target = null
	var closest_distance = 999999.0
	
	for enemy in enemies:
		if enemy == current_enemy or !is_instance_valid(enemy):
			continue
			
		var dist = global_position.distance_to(enemy.global_position)
		if dist < closest_distance:
			closest_distance = dist
			next_target = enemy
			
	if next_target != null:
		direction = (next_target.global_position - global_position).normalized()
	else:
		var current_angle = atan2(direction.y, direction.x)
		var random_angle = current_angle + PI + randf_range(-PI/4, PI/4)
		direction = Vector2(cos(random_angle), sin(random_angle))
		direction = direction.normalized()
