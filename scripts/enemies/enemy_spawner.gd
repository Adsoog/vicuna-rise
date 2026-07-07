extends Node2D

var enemy_scenes = [
	preload("res://scenes/enemies/hunter.tscn"),
	preload("res://scenes/enemies/orc.tscn")
]
var patrol_scene = preload("res://scenes/enemies/patrol_path.tscn")

@onready var spawn_timer = $SpawnTimer

var player = null
var spawn_radius = 450.0
var min_spawn_time = 0.3
var difficulty_rate = 0.015

func _ready():
	call_deferred("find_player")
	if spawn_timer:
		spawn_timer.wait_time = 1.5
		
	var patrol = patrol_scene.instantiate()
	get_parent().call_deferred("add_child", patrol)
	patrol.global_position = Vector2.ZERO
	
	var elite_timer = Timer.new()
	elite_timer.wait_time = 100.0
	elite_timer.autostart = true
	elite_timer.timeout.connect(spawn_elite_enemy)
	add_child(elite_timer)

func spawn_elite_enemy():
	if player == null or not is_instance_valid(player) or enemy_scenes.size() == 0:
		return
	print("¡Apareció un Enemigo Élite!")
	var elite = enemy_scenes[0].instantiate()
	elite.hits_to_die = 3
	elite.speed = 135.0
	elite.scale = Vector2(1.5, 1.5)
	elite.modulate = Color(2.0, 0.3, 2.0, 1.0)
	elite.xp_drop_amount = 600
	
	var angle = randf() * PI * 2
	var offset = Vector2(cos(angle), sin(angle)) * spawn_radius
	elite.global_position = player.global_position + offset
	get_parent().add_child(elite)
	
	var hud = get_tree().current_scene.get_node_or_null("Vicuna/HUD")
	if hud and hud.has_method("show_notification"):
		hud.show_notification("⚠️ ¡ENEMIGO ÉLITE DETECTADO! ⚠️")

func find_player():
	var nodes = get_tree().get_nodes_in_group("player")
	if nodes.size() > 0:
		player = nodes[0]
	else:
		player = get_parent().get_node_or_null("Vicuna")

func _on_spawn_timer_timeout():
	if player == null or enemy_scenes.size() == 0:
		return
		
	if get_tree().get_nodes_in_group("enemy").size() >= 85:
		return
		
	var available_scenes = [enemy_scenes[0]]
	if "current_level" in player and enemy_scenes.size() > 1:
		if player.current_level >= 4:
			available_scenes.append(enemy_scenes[1])
		if player.current_level >= 7:
			available_scenes.append(enemy_scenes[1])
			available_scenes.append(enemy_scenes[1])
			available_scenes.append(enemy_scenes[1])
			
			if randf() < 0.05:
				spawn_elite_enemy()
				
	var random_scene = available_scenes[randi() % available_scenes.size()]
	var enemy = random_scene.instantiate()
	
	var angle = randf() * PI * 2
	var offset = Vector2(cos(angle), sin(angle)) * spawn_radius
	enemy.global_position = player.global_position + offset
	
	get_parent().add_child(enemy)
	
	if spawn_timer.wait_time > min_spawn_time:
		spawn_timer.wait_time = max(min_spawn_time, spawn_timer.wait_time - difficulty_rate)
