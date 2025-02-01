extends Node2D

var wrong_letters = 0
const MAX_WRONG_LETTERS = 10
var word_list = [] 
var game_active = true
var current_level = 1

# Preselect the next enemy’s word.
var next_word: String = ""

@onready var player = $Player
@onready var spawn_timer = $SpawnTimer
@onready var enemy_container = $EnemyContainer
@onready var ui_layer = $UI
@onready var score_label: Label = $UI/ScoreLabel
@onready var mistakes_label: Label = $UI/MistakesLabel
@onready var level_label: Label = $UI/LevelLabel

var current_enemy_speed = 80
var score = 0
# Preload scenes
var enemy_scene = preload("res://scenes/enemy.tscn")
var laser_scene = preload("res://scenes/laser.tscn")

func _ready():
	randomize()
	load_words()
	if word_list.size() > 0:
		next_word = word_list[randi() % word_list.size()]
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	player.shoot_laser.connect(_on_player_shoot)
	player.player_hit.connect(_on_player_hit)
	setup_ui()
	spawn_timer.start()
	AudioManager.background_music.play()
	
func _on_player_hit():
	game_over()

func load_words():
	var file: FileAccess = FileAccess.open("res://assets/en.json", FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		file.close()
		var json_parser = JSON.new()
		var err: int = json_parser.parse(json_text)
		if err != 0:
			push_error("Error parsing JSON file: " + json_parser.get_error_message())
			return
		var data = json_parser.data
		if data.has("words"):
			for word_obj in data["words"]:
				if word_obj.has("englishWord"):
					var word = str(word_obj["englishWord"]).strip_edges().to_lower()
					if word != "":
						word_list.append(word)
		else:
			push_error("JSON file doesn't have a 'words' key!")
	else:
		push_error("Could not open en.json!")

func _input(event):
	if not game_active:
		return
		
	if event is InputEventKey and event.pressed:
		AudioManager.type.play()
		var typed_char = char(event.keycode).to_lower()
		check_typed_letter(typed_char)

func check_typed_letter(letter: String):
	var enemies = enemy_container.get_children()
	for enemy in enemies:
		if not enemy.current_letters.is_empty() and enemy.current_letters[0] == letter:
			var first_letter_scene = enemy.letter_scenes[0]
			if is_instance_valid(first_letter_scene):
				update_score(10)
				AudioManager.correct_letter.play()
				var target_pos = first_letter_scene.global_position
				player.shoot(target_pos)
				enemy.destroy_letter(letter)
				return
	AudioManager.wrong_letter.play()
	wrong_letters += 1
	update_mistakes_ui()
	
	if wrong_letters >= MAX_WRONG_LETTERS:
		game_over()
		
func update_score(amount) -> void:
	score += amount
	score_label.text = "Score: %d" % score
	var new_level = (score / 500) + 1
	print(current_level, new_level)
	if new_level > current_level:
		current_level += 1
		animate_level_label()
		AudioManager.next_level.play()
	level_label.text = "Level: %d" % new_level
	
	var new_speed = 80 + int(score / 500) * 10

	# If the new speed is higher, apply it to all enemies.
	if new_speed > current_enemy_speed:
		current_enemy_speed = new_speed
		update_enemy_speeds()
		
func animate_level_label():
	# Set the pivot/origin to the center of the label for scaling
	level_label.pivot_offset = level_label.size / 2
	
	# Create separate tweens for different animation groups
	var main_tween = create_tween()
	main_tween.set_parallel(true)  # Parallel for the main animations
	
	# Store original position and rotation
	var original_pos = level_label.position
	var original_rotation = level_label.rotation
	
	# Bright blue color animation
	main_tween.tween_property(level_label, "modulate", Color(0, 0.5, 1), 0.5)
	main_tween.tween_property(level_label, "modulate", Color.WHITE, 0.3)\
		.set_delay(1)  # Start after the blue animation
	
	# Smooth scale animation with slight bounce
	main_tween.tween_property(level_label, "scale", Vector2(1.1, 1.1), 0.2)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
	main_tween.tween_property(level_label, "scale", Vector2(1, 1), 0.2)\
		.set_trans(Tween.TRANS_BOUNCE)\
		.set_ease(Tween.EASE_OUT)\
		.set_delay(0.3)  # Start after scaling up
	
	# Create a separate sequential tween for shake effects
	var shake_tween = create_tween()
	shake_tween.set_parallel(false)  # Make sure shakes happen in sequence
	
	# Enhanced vibration effect with rotation
	var shake_strength = 3.0
	var shake_duration = 0.03  # Shorter duration for more rapid shakes
	var num_shakes = 7  # Number of shakes
	var rotation_strength = 0.05  # Rotation in radians
	
	for i in range(num_shakes):
		var random_offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
		var random_rotation = randf_range(-rotation_strength, rotation_strength)
		
		# Position and rotation shake (happening together)
		var shake_group = create_tween()
		shake_group.set_parallel(true)  # Position and rotation shake together
		
		shake_group.tween_property(
			level_label, 
			"position", 
			original_pos + random_offset, 
			shake_duration
		).set_trans(Tween.TRANS_SINE)
		
		shake_group.tween_property(
			level_label,
			"rotation",
			original_rotation + random_rotation,
			shake_duration
		).set_trans(Tween.TRANS_SINE)
		
		# Wait for this shake group to finish
		await shake_group.finished
	
	# Final reset of position and rotation
	var final_tween = create_tween()
	final_tween.set_parallel(true)
	
	final_tween.tween_property(
		level_label, 
		"position", 
		original_pos, 
		shake_duration
	).set_trans(Tween.TRANS_SINE)
	
	final_tween.tween_property(
		level_label,
		"rotation",
		original_rotation,
		shake_duration
	).set_trans(Tween.TRANS_SINE)

		
func update_enemy_speeds():
	var enemies = enemy_container.get_children()
	for enemy in enemies:
		enemy.set_speed(current_enemy_speed)  # Update each enemy's speed
	

func _on_spawn_timer_timeout():
	spawn_enemy()

func spawn_enemy():
	# Create enemy and assign the preselected next word.
	var enemy = enemy_scene.instantiate()
	enemy.word = next_word
	enemy.speed = current_enemy_speed  # Always use the latest speed
	enemy.position = Vector2(1300, 500)
	enemy_container.add_child(enemy)
	enemy.enemy_died.connect(_on_enemy_died)
	
	next_word = word_list[randi() % word_list.size()]
	
	var letter_width: float = 36.0
	var desired_gap: float = 30.0
	var current_word_width = enemy.word.length() * letter_width
	var next_word_width = next_word.length() * letter_width
	
	var distance: float = current_word_width / 2.0 + desired_gap + next_word_width / 2.0
	
	var delay: float = distance / enemy.speed
	spawn_timer.wait_time = delay
	spawn_timer.start()

func _on_enemy_died():
	update_score(50)
	
func _on_player_shoot(start_pos: Vector2, target_pos: Vector2):
	var laser = laser_scene.instantiate()
	add_child(laser)
	laser.shoot(start_pos, target_pos)

func game_over():
	AudioManager.game_over.play()
	game_active = false
	spawn_timer.stop()
	show_game_over_screen()
	

func setup_ui():
	pass

func update_mistakes_ui():
	mistakes_label.text = "Mistakes: %d" %wrong_letters

func show_game_over_screen():
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()
