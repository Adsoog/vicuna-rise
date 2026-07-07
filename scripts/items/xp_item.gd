extends Area2D

var xp_value = 10
var speed = 180.0
var player = null
var attracted = false

func _ready():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func _process(delta):
	if attracted and player != null:
		var direction = (player.global_position - global_position).normalized()
		global_position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("gain_xp"):
			body.gain_xp(xp_value)
		queue_free()
