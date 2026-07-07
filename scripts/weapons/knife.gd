extends Area2D

var speed = 160.0
var direction = Vector2.ZERO
var lifetime = 0.95

func _process(delta):
	var target = get_closest_enemy()
	if target:
		var desired_dir = (target.global_position - global_position).normalized()
		direction = direction.lerp(desired_dir, 4.0 * delta).normalized()
		
	position += direction * speed * delta
	
	lifetime -= delta
	if lifetime <= 0:
		queue_free()

func get_closest_enemy():
	var enemies = get_tree().get_nodes_in_group("enemy")
	var closest = null
	var min_dist = 999999.0
	for enemy in enemies:
		if not is_instance_valid(enemy) or not enemy.visible or enemy.process_mode == PROCESS_MODE_DISABLED: continue
		var d = global_position.distance_to(enemy.global_position)
		if d < min_dist:
			min_dist = d
			closest = enemy
	return closest

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		if body.has_method("die"):
			body.die()
		else:
			body.queue_free()
		queue_free()
