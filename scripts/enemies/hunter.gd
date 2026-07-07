extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D

var xp_scene = preload("res://scenes/items/xp_item.tscn")
var explosion_scene = preload("res://scenes/effects/explosion.tscn")

var player
var speed = 75.0
var last_direction = "down"
var hits_to_die = 1
var current_hits = 0
var xp_drop_amount = 10

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if player == null:
		return
		
	if global_position.distance_to(player.global_position) > 1050.0:
		var angle = randf() * PI * 2
		global_position = player.global_position + Vector2(cos(angle), sin(angle)) * 450.0

	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()
	
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider and collider.is_in_group("player"):
			if collider.has_method("take_damage"):
				collider.take_damage(15)
	
	if velocity.length() > 0:
		update_direction_string(direction)
		if global_position.distance_to(player.global_position) < 38.0:
			update_animation("run_attack")
		else:
			update_animation("run")
	else:
		update_animation("run")

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
	current_hits += 1
	if current_hits < hits_to_die:
		modulate = Color(3.0, 3.0, 3.0, 1.0)
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.15)
		return
		
	var xp = xp_scene.instantiate()
	xp.xp_value = xp_drop_amount
	if xp_drop_amount > 20:
		xp.scale = Vector2(1.5, 1.5)
		xp.modulate = Color(1.2, 0.8, 2.0, 1.0)
	if xp_drop_amount > 100:
		xp.scale = Vector2(2.2, 2.2)
		xp.modulate = Color(2.0, 1.5, 0.2, 1.0)
	get_parent().add_child(xp)
	xp.global_position = global_position
	
	var explosion = explosion_scene.instantiate()
	get_parent().add_child(explosion)
	explosion.global_position = global_position
	
	queue_free()
