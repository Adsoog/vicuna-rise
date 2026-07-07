extends Area2D

var length = 70.0
var current_angle = 0.0
var sweep_speed = 5.0
var lifetime = 0.8
var max_lifetime = 0.8

@onready var line_2d = $Line2D
@onready var collision_shape = $CollisionShape2D

func _ready():
	current_angle = randf() * PI * 2.0
	
	line_2d.width = 0.0
	line_2d.default_color = Color(0.75, 0.25, 1.0, 1.0)
	
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1.0, 0.85, 1.0, 1.0))
	gradient.add_point(0.5, Color(0.75, 0.2, 1.0, 1.0))
	gradient.add_point(1.0, Color(0.4, 0.0, 0.8, 0.8))
	line_2d.gradient = gradient
	
	body_entered.connect(_on_body_entered)


func _physics_process(delta):
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()
		return
		
	current_angle += sweep_speed * delta
	
	var end_point = Vector2(cos(current_angle), sin(current_angle)) * length
	
	line_2d.clear_points()
	line_2d.add_point(Vector2.ZERO)
	line_2d.add_point(end_point)
	
	if collision_shape.shape is SegmentShape2D:
		collision_shape.shape.a = Vector2.ZERO
		collision_shape.shape.b = end_point
		
	var progress = 1.0 - (lifetime / max_lifetime)
	if progress < 0.15:
		line_2d.width = lerp(0.0, 9.0, progress / 0.15)
	elif progress > 0.75:
		line_2d.width = lerp(9.0, 0.0, (progress - 0.75) / 0.25)
	else:
		line_2d.width = 9.0 + sin(progress * 45.0) * 2.0
		
	var bodies = get_overlapping_bodies()
	for body in bodies:
		hit_enemy(body)

func _on_body_entered(body):
	hit_enemy(body)

func hit_enemy(body):
	if body.is_in_group("enemy") and is_instance_valid(body):
		if body.has_method("die"):
			body.die()
		else:
			body.queue_free()
