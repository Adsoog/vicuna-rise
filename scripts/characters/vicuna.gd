extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite
@onready var attack_timer = $AttackTimer
@onready var magic_timer = $MagicTimer
@onready var axe_timer = $AxeTimer
@onready var bounce_timer = $BounceTimer

var knife_scene = preload("res://scenes/weapons/knife.tscn")
var missile_scene = preload("res://scenes/weapons/magic_missile.tscn")
var axe_scene = preload("res://scenes/weapons/axe.tscn")
var bouncer_scene = preload("res://scenes/weapons/bouncer.tscn")
var laser_scene = preload("res://scenes/weapons/laser.tscn")
var rose_scene = preload("res://scenes/weapons/orbit_rose.tscn")
var hud_scene = preload("res://scenes/ui/hud.tscn")

var laser_timer: Timer
var rose_timer: Timer

var speed = 80.0
var last_direction = "down"

var current_xp = 0
var current_level = 1
var xp_needed_for_level = 90

var max_hp = 200
var current_hp = 200
var is_invulnerable = false

var hud = null

var locked_weapons = ["axe", "magic", "bounce", "rose", "laser"]

func _ready():
	magic_timer.stop()
	axe_timer.stop()
	bounce_timer.stop()
	
	attack_timer.wait_time = 1.10
	magic_timer.wait_time = 2.5
	axe_timer.wait_time = 2.2
	bounce_timer.wait_time = 2.8
	attack_timer.start()
	
	laser_timer = Timer.new()
	laser_timer.wait_time = 3.2
	laser_timer.autostart = false
	laser_timer.timeout.connect(_on_laser_timer_timeout)
	add_child(laser_timer)
	
	rose_timer = Timer.new()
	rose_timer.wait_time = 4.8
	rose_timer.autostart = false
	rose_timer.timeout.connect(_on_rose_timer_timeout)
	add_child(rose_timer)
	
	hud = hud_scene.instantiate()
	add_child(hud)
	update_hud_display()

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
	
	update_animation("run")
	velocity = input_direction * speed

func update_animation(state):
	animated_sprite.play(state + "_" + last_direction)

func update_hud_display():
	if hud:
		hud.update_hp(current_hp, max_hp)
		hud.update_xp(current_xp, xp_needed_for_level, current_level)

func gain_xp(amount):
	current_xp += amount
	print("XP Ganada: ", current_xp, "/", xp_needed_for_level)
	while current_xp >= xp_needed_for_level:
		level_up()
	update_hud_display()

func level_up():
	current_xp -= xp_needed_for_level
	current_level += 1
	xp_needed_for_level = int(xp_needed_for_level * 1.45)
	
	speed += 6.5
	current_hp = min(max_hp, current_hp + 120)
	update_hud_display()
	print("¡SUBISTE DE NIVEL! Nivel actual: ", current_level, " | Vida: +120 | Vel: ", speed)
	
	var weapon_msg = unlock_random_weapon()
	play_level_up_effect(weapon_msg)

func play_level_up_effect(weapon_msg: String):
	if animated_sprite:
		animated_sprite.modulate = Color(2.5, 2.2, 0.5)
		animated_sprite.scale = Vector2(1.35, 1.35)
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(animated_sprite, "modulate", Color(1, 1, 1, 1), 0.8)
		tween.tween_property(animated_sprite, "scale", Vector2(1.0, 1.0), 0.8).set_trans(Tween.TRANS_BOUNCE)
	
	if hud and hud.has_method("show_notification"):
		hud.show_notification("¡NIVEL " + str(current_level) + " ALCANZADO!\n" + weapon_msg)

func take_damage(amount):
	if is_invulnerable or current_hp <= 0:
		return
	
	current_hp -= amount
	print("¡Vicuña recibió daño! Vida restante: ", current_hp)
	update_hud_display()
	
	if current_hp <= 0:
		die()
	else:
		become_invulnerable()

func become_invulnerable():
	is_invulnerable = true
	if animated_sprite:
		animated_sprite.modulate = Color(1, 0.3, 0.3, 0.8)
	await get_tree().create_timer(0.6).timeout
	if animated_sprite:
		animated_sprite.modulate = Color(1, 1, 1, 1)
	is_invulnerable = false

func die():
	print("¡La vicuña ha caído!")
	get_tree().reload_current_scene()

func unlock_random_weapon() -> String:
	if locked_weapons.size() == 0:
		print("¡Ya tienes todas las armas al máximo!")
		return "¡Poder MÁXIMO!"
		
	var weapon_to_unlock = locked_weapons[0]
	locked_weapons.remove_at(0)
	
	match weapon_to_unlock:
		"magic":
			magic_timer.start()
			print("¡Arma Desbloqueada: Misil Mágico Giratorio!")
			return "¡Misil Mágico Desbloqueado!"
		"axe":
			axe_timer.start()
			print("¡Arma Desbloqueada: Hacha Parabólica!")
			return "¡Hacha Parabólica Desbloqueada!"
		"bounce":
			bounce_timer.start()
			print("¡Arma Desbloqueada: Cuchillo Rebotador!")
			return "¡Cuchillo Rebotador Desbloqueado!"
		"laser":
			laser_timer.start()
			print("¡Arma Desbloqueada: Láser Morado Trigonométrico!")
			return "¡Láser Morado Desbloqueado!"
		"rose":
			rose_timer.start()
			print("¡Arma Desbloqueada: Rosa Polar Orbital!")
			return "¡Rosa Polar Desbloqueada!"
	return "¡Nuevo Ataque Desbloqueado!"

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

# --- EXPLICACIÓN DE TRIGONOMETRÍA Y DISPERSIÓN (SPREAD - MISIL MÁGICO) ---
# Esta función genera un abanico (spread) de 3 misiles utilizando trigonometría básica:
# 1. Ángulo Base (θ): Se determina según hacia dónde mira el jugador en radianes (0, π/2, π, -π/2).
# 2. Desviación Angular (Δθ): Usamos deg_to_rad(20) para desviar el disparo central en ±20 grados.
# 3. Conversión de Ángulo a Vector Direccional (x, y): Para cada ángulo resultante, calculamos el
#    vector unitario de dirección aplicando trigonometría en el círculo unitario:
#    dir = Vector2(cos(θ), sin(θ))
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
	for i in range(2):
		var axe = axe_scene.instantiate()
		axe.speed_x = -130.0 if i == 0 else 130.0
		get_parent().add_child(axe)
		axe.global_position = global_position

func _on_bounce_timer_timeout() -> void:
	var bouncer = bouncer_scene.instantiate()
	var random_angle = randf() * PI * 2
	bouncer.set("direction", Vector2(cos(random_angle), sin(random_angle)))
	get_parent().add_child(bouncer)
	bouncer.global_position = global_position

func _on_laser_timer_timeout() -> void:
	var laser = laser_scene.instantiate()
	laser.length = 70.0 + (current_level * 10.0)
	add_child(laser)
	laser.position = Vector2.ZERO

func _on_rose_timer_timeout() -> void:
	var rose = rose_scene.instantiate()
	add_child(rose)
	rose.position = Vector2.ZERO
