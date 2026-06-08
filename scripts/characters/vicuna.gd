extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite
@onready var attack_timer = $AttackTimer
@onready var magic_timer = $MagicTimer
@onready var axe_timer = $AxeTimer
@onready var bounce_timer = $BounceTimer

var knife_scene = preload("res://Scenes/Weapons/Knife.tscn")
var missile_scene = preload("res://Scenes/Weapons/MagicMissile.tscn")
var axe_scene = preload("res://Scenes/Weapons/Axe.tscn")
var bouncer_scene = preload("res://Scenes/Weapons/Bouncer.tscn")

var speed = 80.0
var last_direction = "down"

var current_xp = 0
var current_level = 1
var xp_needed_for_level = 100

var locked_weapons = ["magic", "axe", "bounce"]

func _ready():
	magic_timer.stop()
	axe_timer.stop()
	bounce_timer.stop()
	
	attack_timer.start()

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

func gain_xp(amount):
	current_xp += amount
	print("XP Ganada: ", current_xp, "/", xp_needed_for_level)
	if current_xp >= xp_needed_for_level:
		level_up()

func level_up():
	current_xp -= xp_needed_for_level
	current_level += 1
	xp_needed_for_level = int(xp_needed_for_level * 1.5)
	print("¡SUBISTE DE NIVEL! Nivel actual: ", current_level)
	
	unlock_random_weapon()

func unlock_random_weapon():
	if locked_weapons.size() == 0:
		print("¡Ya tienes todas las armas al máximo!")
		return
		
	randomize()
	var random_index = randi() % locked_weapons.size()
	var weapon_to_unlock = locked_weapons[random_index]
	
	locked_weapons.remove_at(random_index)
	
	match weapon_to_unlock:
		"magic":
			magic_timer.start()
			print("¡Arma Desbloqueada: Misil Mágico Giratorio!")
		"axe":
			axe_timer.start()
			print("¡Arma Desbloqueada: Hacha Parabólica!")
		"bounce":
			bounce_timer.start()
			print("¡Arma Desbloqueada: Cuchillo Rebotador!")

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

func _on_magic_timer_timeout() -> void:
	var base_angle = 0.0
	
	match last_direction:
		"right": base_angle = 0.0
		"down": base_angle = PI / 2.0
		"left": base_angle = PI
		"up": base_angle = -PI / 2.0

	var angles = [
		base_angle - deg_to_rad(20),
		base_angle,
		base_angle + deg_to_rad(20)
	]

	for angle in angles:
		var missile = missile_scene.instantiate()
		var dir = Vector2(cos(angle), sin(angle))
		
		missile.set("direction", dir)
		get_parent().add_child(missile)
		missile.global_position = global_position

func _on_axe_timer_timeout() -> void:
	var axe = axe_scene.instantiate()
	get_parent().add_child(axe)
	axe.global_position = global_position

func _on_bounce_timer_timeout() -> void:
	var bouncer = bouncer_scene.instantiate()
	var random_angle = randf() * PI * 2
	bouncer.set("direction", Vector2(cos(random_angle), sin(random_angle)))
	get_parent().add_child(bouncer)
	bouncer.global_position = global_position
