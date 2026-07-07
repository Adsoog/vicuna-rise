extends "res://scripts/enemies/hunter.gd"

func _ready():
	super._ready()
	hits_to_die = 2
	speed = 65.0
	xp_drop_amount = 30
