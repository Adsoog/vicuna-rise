extends "res://scripts/enemies/hunter.gd"

func _ready():
	super._ready()
	hits_to_die = 3
	speed = 130.0
	scale = Vector2(1.5, 1.5)
	modulate = Color(2.0, 0.3, 2.0, 1.0)
