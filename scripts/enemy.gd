extends CharacterBody2D

signal enemy_died
signal letter_destroyed(letter: String)

@export var speed = 80
@export var word = ""
# Base offset above enemy’s origin (where the head is located)
@export var enemy_line_offset: Vector2 = Vector2(0, -50)
# Offset for where the line connects to the letter (e.g. below the letter box)
@export var letter_line_offset: Vector2 = Vector2(0, 20)
# How far (in pixels) along the line’s direction to start drawing the line,
# so it “peels off” from the enemy’s head.
@export var line_start_extra_offset: float = 20

@onready var animated_sprite = $AnimatedSprite2D
@onready var letter_container = $LetterContainer
@onready var particles: GPUParticles2D = $GPUParticles2D
@onready var hit_box = $HitBox

var current_letters = []
var letter_scenes = []
var letter_lines = []  # New array to store each letter's connection line
var letter_scene = preload("res://scenes/letter.tscn")

func _ready():
	velocity.x = -speed
	animated_sprite.play("walking")
	setup_word()
	hit_box.add_to_group("enemy_hitbox")

func setup_word():
	var spacing = 36
	var start_x = -word.length() * spacing / 2
	
	
	# Loop through each letter in the word.
	for i in word.length():
		var letter_instance = letter_scene.instantiate()
		letter_instance.position.x = start_x + i * spacing
		# This positions the letter above the enemy.
		letter_instance.position.y = -200
		letter_instance.setup(word[i])
		letter_container.add_child(letter_instance)
		letter_scenes.append(letter_instance)
		current_letters.append(word[i])
		
		# Determine the endpoint for the connection line:
		var letter_endpoint = letter_instance.position + letter_line_offset
		
		# Compute the direction from the enemy’s head (enemy_line_offset)
		# to the letter's endpoint.
		var direction = (letter_endpoint - enemy_line_offset).normalized()
		# Offset the starting point along that direction.
		var line_start = enemy_line_offset + direction * line_start_extra_offset
		
		var line = Line2D.new()
		line.add_point(line_start)
		line.add_point(letter_endpoint)
		line.width = 1.0
		# Set the line's color to white with 70% transparency.
		line.default_color = Color(1, 1, 1, 0.1)
		letter_container.add_child(line)
		letter_lines.append(line)  # Save the line reference for later removal

func _physics_process(_delta):
	velocity.x = -speed
	move_and_slide()
	
func set_speed(new_speed: float):
	speed = new_speed  

func destroy_letter(letter: String):
	var index = current_letters.find(letter)
	if index != -1 and index < letter_scenes.size():
		var letter_node = letter_scenes[index]
		if is_instance_valid(letter_node):
			# Remove letter and its corresponding line from the arrays
			current_letters.remove_at(index)
			letter_scenes.remove_at(index)
			var line_node = letter_lines[index]
			if is_instance_valid(line_node):
				line_node.queue_free()
			letter_lines.remove_at(index)
			
			letter_node.hit()  # This will queue_free the letter
			letter_destroyed.emit(letter)
			
			if current_letters.is_empty():
				die()

func die():
	particles.emitting = true
	enemy_died.emit()
	AudioManager.word_complete.play()
	animated_sprite.play("death")
	velocity.x = 0
	set_physics_process(false)
	await animated_sprite.animation_finished
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	await tween.finished
	queue_free()
