extends CharacterBody2D

var xp_scene = preload("res://scenes/items/xp_item.tscn")
var explosion_scene = preload("res://scenes/effects/explosion.tscn")

var hits_to_die = 2
var current_hits = 0

func _ready():
	var damage_area = $DamageArea
	if damage_area:
		damage_area.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(20)

func die():
	current_hits += 1
	if current_hits < hits_to_die:
		modulate = Color(3.0, 3.0, 3.0, 1.0)
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color(1.0, 0.2, 0.2, 1.0), 0.15)
		return
		
	var xp = xp_scene.instantiate()
	get_tree().current_scene.add_child(xp)
	xp.global_position = global_position
	
	var explosion = explosion_scene.instantiate()
	get_tree().current_scene.add_child(explosion)
	explosion.global_position = global_position
	
	visible = false
	process_mode = PROCESS_MODE_DISABLED
	
	var timer = get_tree().create_timer(30.0)
	timer.timeout.connect(respawn)

func respawn():
	hits_to_die += 1
	current_hits = 0
	
	var path_root = get_node_or_null("../..")
	if path_root and "speed" in path_root:
		path_root.speed += 35.0
		
	visible = true
	process_mode = PROCESS_MODE_INHERIT
	
	var hud = get_tree().current_scene.get_node_or_null("Vicuna/HUD")
	if hud and hud.has_method("show_notification"):
		hud.show_notification("⚠️ ¡EL PATROL ROJO REAPARECIÓ MÁS FUERTE Y VELOZ! ⚠️")
