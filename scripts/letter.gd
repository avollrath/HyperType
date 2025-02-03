# letter.gd
extends Node2D

signal letter_hit
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var letter = ""
var is_active = true

# Remove @onready since we'll handle initialization differently
var background: Panel
var label: Label
var initialized = false

func _ready():
	background = $Background
	label = $Label
	initialized = true
	
	
	if letter != "":  # If setup was called before _ready
		_apply_setup()
	else:
		setup_visuals()

func setup(new_letter: String):
	letter = new_letter
	if initialized:
		_apply_setup()

func _apply_setup():
	if label:
		label.text = letter
		setup_visuals()
	else:
		push_error("Label node not found in Letter scene")

func setup_visuals():
	if background:
		background.size = Vector2(42, 42)
		background.position = Vector2(-21, -21)
	else:
		print("Background node not found!")
	
	if label:
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.size = Vector2(42, 42)
		label.position = Vector2(-21, -23)
	else:
		print("Label node not found!")

func hit():
	if is_active:
		letter_hit.emit()
		await get_tree().create_timer(0.05).timeout
		animated_sprite.rotation_degrees = randf_range(0, 360)
		animated_sprite.show()
		animated_sprite.play()
		await animated_sprite.animation_finished
		is_active = false
		var tween = create_tween()
		animated_sprite.hide()
		var target_color = Color(1.0, 0.5, 0.0, 0.0)  # Orange with alpha 0
		tween.tween_property(self, "modulate", target_color, 0.02)
		await tween.finished
		queue_free()
