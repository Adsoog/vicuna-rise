extends Area2D

var speed = 135.0
var direction = Vector2.ZERO
var bounces_left = 3 
var rotation_speed = 8.0
var lifetime = 2.5

func _process(delta):
	position += direction * speed * delta
	rotation += rotation_speed * delta
	scale = scale.lerp(Vector2(1.0, 1.0), 12.0 * delta)
	
	lifetime -= delta
	if lifetime <= 0:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		if body.has_method("die"):
			body.die()
		else:
			body.queue_free()
		
		create_bounce_spark()
		scale = Vector2(1.6, 1.6)
		
		bounces_left -= 1
		if bounces_left <= 0:
			queue_free()
		else:
			rebound_to_next_enemy(body)

func create_bounce_spark():
	var spark = CPUParticles2D.new()
	spark.emitting = false
	spark.one_shot = true
	spark.explosiveness = 0.9
	spark.amount = 12
	spark.lifetime = 0.35
	spark.spread = 180.0
	spark.initial_velocity_min = 70.0
	spark.initial_velocity_max = 150.0
	spark.scale_amount_min = 2.0
	spark.scale_amount_max = 4.5
	spark.color = Color(1.0, 0.9, 0.2, 1.0)
	get_parent().add_child(spark)
	spark.global_position = global_position
	spark.emitting = true
	
	var timer = Timer.new()
	timer.wait_time = 0.4
	timer.one_shot = true
	timer.autostart = true
	timer.timeout.connect(spark.queue_free)
	spark.add_child(timer)

func rebound_to_next_enemy(current_enemy):
	var enemies = get_tree().get_nodes_in_group("enemy")
	var next_target = null
	var closest_distance = 999999.0
	
	for enemy in enemies:
		if enemy == current_enemy or !is_instance_valid(enemy) or not enemy.visible or enemy.process_mode == PROCESS_MODE_DISABLED:
			continue
			
		var dist = global_position.distance_to(enemy.global_position)
		if dist < closest_distance:
			closest_distance = dist
			next_target = enemy
			
	if next_target != null:
		var ray_dir = (next_target.global_position - global_position).normalized()
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsRayQueryParameters2D.create(global_position, next_target.global_position)
		var result = space_state.intersect_ray(query)
		if result and result.collider == next_target:
			direction = ray_dir
		else:
			direction = ray_dir
	else:
		var current_angle = atan2(direction.y, direction.x)
		var random_angle = current_angle + PI + randf_range(-PI/4, PI/4)
		direction = Vector2(cos(random_angle), sin(random_angle)).normalized()
