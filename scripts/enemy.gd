# base_enemy.gd
extends CharacterBody2D

signal enemy_died
signal letter_destroyed(letter: String)

@export var speed = 80
@export var word = ""
@export var enemy_line_offset: Vector2 = Vector2(0, -60)
@export var letter_line_offset: Vector2 = Vector2(0, 30)
@export var line_start_extra_offset: float = 100
var is_dying: bool = false

@onready var animated_sprite = $AnimatedSprite2D
@onready var letter_container = $LetterContainer
@onready var hit_box = $HitBox
@onready var point_light_2d = get_node_or_null("PointLight2D")
@onready var step_particles = get_node_or_null("StepParticles")

var current_letters = []
var letter_scenes = []
var letter_lines = []
var letter_scene = preload("res://scenes/letter.tscn")

var light_scale: Vector2 = Vector2(1.5, 1.5)

var last_frame = 0
var emission_frames = [2, 4] 

func _ready():
	if point_light_2d:
		var tween = create_tween()
		point_light_2d.enabled = true
		tween.tween_property(point_light_2d, "scale", Vector2(0.1, 0.1), 0.1).set_trans(Tween.TRANS_LINEAR)
		await tween.finished  
		point_light_2d.enabled = false
	velocity.x = -speed
	animated_sprite.play("walking")
	setup_word()
	hit_box.add_to_group("enemy_hitbox")
	_after_ready()  # Hook for child classes

func _after_ready():
	pass  # Override in child classes to add specific initialization

func setup_word():
	var spacing = 44
	var start_x = -word.length() * spacing / 2
	
	for i in word.length():
		var letter_instance = letter_scene.instantiate()
		letter_instance.position.x = start_x + i * spacing
		letter_instance.position.y = -300
		letter_instance.setup(word[i])
		letter_container.add_child(letter_instance)
		letter_scenes.append(letter_instance)
		current_letters.append(word[i])
		
		var letter_endpoint = letter_instance.position + letter_line_offset
		var direction = (letter_endpoint - enemy_line_offset).normalized()
		var line_start = enemy_line_offset + direction * line_start_extra_offset
		
		var line = Line2D.new()
		line.set_end_cap_mode(Line2D.LINE_CAP_ROUND)
		line.set_begin_cap_mode(Line2D.LINE_CAP_ROUND)
		line.add_point(line_start)
		line.add_point(letter_endpoint)
		line.width = 3.0
		line.default_color = Color(1, 1, 1, 0.4)
		letter_container.add_child(line)
		letter_lines.append(line)

func _physics_process(_delta):
	velocity.x = -speed
	move_and_slide()
	
	if step_particles and animated_sprite:
		var current_frame = animated_sprite.frame
		if current_frame != last_frame:
			if current_frame == 3:
				# Frame 1: Create duplicate of original particle system
				var new_original = step_particles.duplicate()
				add_child(new_original)
				new_original.emitting = true
				
				# Clean up after emission
				await get_tree().create_timer(0.3).timeout
				new_original.queue_free()
				
			elif current_frame == 1:
				# Frame 3: Create duplicate for background particles
				var new_back_particles = step_particles.duplicate()
				add_child(new_back_particles)
				new_back_particles.z_index = 0
				new_back_particles.emitting = true
				
				# Clean up after emission
				await get_tree().create_timer(0.3).timeout
				new_back_particles.queue_free()
		
		last_frame = current_frame

func _after_physics_process():
	pass  # Override in child classes for custom movement

func set_speed(new_speed: float):
	speed = new_speed

func destroy_letter(letter: String):
	var index = current_letters.find(letter)
	if index != -1 and index < letter_scenes.size():
		var letter_node = letter_scenes[index]
		if is_instance_valid(letter_node):
			current_letters.remove_at(index)
			letter_scenes.remove_at(index)
			var line_node = letter_lines[index]
			if is_instance_valid(line_node):
				line_node.queue_free()
			letter_lines.remove_at(index)
			
			letter_node.hit()
			letter_destroyed.emit(letter)
			
			if current_letters.is_empty():
				die()

func die():
	is_dying = true
	enemy_died.emit()
	AudioManager.word_complete.play()
	animated_sprite.play("death")
	var tween = create_tween()
	tween.set_parallel()
	if point_light_2d:
		point_light_2d.enabled = true
		tween.tween_property(point_light_2d, "scale", light_scale, 0.2).set_trans(Tween.TRANS_LINEAR)
		await tween.finished  
		point_light_2d.enabled = false
	tween.tween_property(animated_sprite, "modulate", Color(1.2, 1.2, 1.2), 0.2)
	await animated_sprite.animation_finished
	tween = create_tween()
	tween.tween_property(animated_sprite, "modulate:a", 0.0, 0.2)
	await tween.finished
	queue_free()
	
func flash_letter():
	if letter_scenes.size() > 0:
		letter_scenes[0].flash()
