extends Control

@onready var label = $MarginContainer/VBoxContainer/RichTextLabel
@onready var prompt_label = $MarginContainer/VBoxContainer/PromptLabel

var typing_speed = 0.35
var is_finished_typing = false

func _ready():
	label.visible_ratio = 0.0
	prompt_label.visible = false

func _process(delta):
	if not is_finished_typing:
		label.visible_ratio += delta * typing_speed
		if label.visible_ratio >= 1.0:
			label.visible_ratio = 1.0
			finish_typing()

func finish_typing():
	is_finished_typing = true
	prompt_label.visible = true

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		handle_action()
	elif event is InputEventKey and event.pressed and (event.keycode == KEY_SPACE or event.keycode == KEY_ENTER or event.keycode == KEY_ESCAPE):
		handle_action()

func handle_action():
	if not is_finished_typing:
		# Si aún está apareciendo el texto, mostrarlo todo instantáneamente
		label.visible_ratio = 1.0
		finish_typing()
	else:
		# Si ya se mostró todo el texto, iniciar el juego en el mapa
		get_tree().change_scene_to_file("res://scenes/levels/level.tscn")
