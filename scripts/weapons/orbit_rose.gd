extends Area2D

var amplitude = 130.0
var k = 3.0
var current_angle = 0.0
var angular_speed = 0.6
var lifetime = 6.0

# --- EXPLICACIÓN DE TRIGONOMETRÍA Y COORDENADAS POLARES (ROSA POLAR) ---
# Esta función utiliza la ecuación paramétrica de la Rosa Polar en coordenadas polares (r, θ):
# 1. Ángulo (θ / current_angle): Aumenta constantemente a una velocidad angular (Δθ = angular_speed * delta).
# 2. Radio (r): Se calcula como r = a * cos(k * θ), donde 'a' es la amplitud (radio máximo del pétalo)
#    y 'k' es la frecuencia o número de pétalos (si k es impar tiene k pétalos; si es par tiene 2k pétalos).
# 3. Conversión Polar a Cartesiana (x, y): Para posicionar el sprite en pantalla 2D, convertimos:
#    x = r * cos(θ)  y  y = r * sin(θ)
# Esto genera una órbita matemática en forma de flor que rodea y protege al jugador.
func _process(delta):
	current_angle += angular_speed * delta
	var r = amplitude * cos(k * current_angle)
	position = Vector2(r * cos(current_angle), r * sin(current_angle))
	
	lifetime -= delta
	if lifetime <= 0:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		if body.has_method("die"):
			body.die()
		else:
			body.queue_free()
