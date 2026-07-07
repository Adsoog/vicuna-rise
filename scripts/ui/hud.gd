extends CanvasLayer

@onready var hp_bar = $MarginContainer/VBoxContainer/HPBar
@onready var hp_label = $MarginContainer/VBoxContainer/HPBar/HPLabel
@onready var xp_bar = $MarginContainer/VBoxContainer/XPBar
@onready var xp_label = $MarginContainer/VBoxContainer/XPBar/XPLabel
@onready var timer_label = $MarginContainer/VBoxContainer/TimerLabel
@onready var notification_label = $NotificationLabel

var time_left = 600.0
var timer_active = true

func _ready():
	update_hp(200, 200)
	update_xp(0, 100, 1)
	if notification_label:
		notification_label.visible = false

func _process(delta):
	if timer_active and time_left > 0:
		time_left -= delta
		if time_left <= 0:
			time_left = 0
			timer_active = false
			on_timer_finished()
		update_timer_label()

func update_timer_label():
	if not timer_label:
		return
	var minutes = int(time_left) / 60
	var seconds = int(time_left) % 60
	timer_label.text = "⏱️ %02d:%02d" % [minutes, seconds]

func on_timer_finished():
	show_notification("¡VICTORIA TOTAL!\n¡Has sobrevivido los 10 minutos!")
	var spawner = get_tree().current_scene.get_node_or_null("EnemySpawner")
	if spawner:
		spawner.queue_free()
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()

func update_hp(current: int, max_hp: int):
	hp_bar.max_value = max_hp
	hp_bar.value = current
	hp_label.text = "Vida: " + str(current) + " / " + str(max_hp)

func update_xp(current: int, needed: int, level: int):
	xp_bar.max_value = needed
	xp_bar.value = current
	xp_label.text = "Nivel " + str(level) + "  |  XP: " + str(current) + " / " + str(needed)

func show_notification(text: String):
	if not notification_label:
		return
	notification_label.text = text
	notification_label.visible = true
	notification_label.modulate = Color(1, 1, 1, 1)
	
	var tween = create_tween()
	tween.tween_interval(2.2) 
	tween.tween_property(notification_label, "modulate:a", 0.0, 0.6)
	tween.tween_callback(func(): notification_label.visible = false)
