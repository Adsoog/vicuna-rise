extends Node2D

var hunter_scene = preload("res://Hunter.tscn")

@onready var spawn_timer = $SpawnTimer

var player = null
var spawn_radius = 450.0
var min_spawn_time = 0.2
var difficulty_rate = 0.02


func _ready():
	call_deferred("find_player")

func find_player():
	var nodes = get_tree().get_nodes_in_group("player")
	if nodes.size() > 0:
		player = nodes[0]
	else:
		player = get_parent().get_node_or_null("Vicuna")

func _on_spawn_timer_timeout():
	if player == null:
		return
		
	var hunter = hunter_scene.instantiate()
	
	var angle = randf() * PI * 2
	var offset = Vector2(cos(angle), sin(angle)) * spawn_radius
	hunter.global_position = player.global_position + offset
	
	get_parent().add_child(hunter)
	
	if spawn_timer.wait_time > min_spawn_time:
		spawn_timer.wait_time = max(min_spawn_time, spawn_timer.wait_time - difficulty_rate)
