extends Node2D

const MAX_WRONG_LETTERS = 10
var word_list = [] 
var game_active = true
var current_level = 1
var next_word: String = ""
var show_game_over = false

# Statistics variables
var score = 0
var start_time: int
var correct_chars: int = 0
var total_chars_typed: int = 0
var wrong_chars: int = 0
var current_streak: int = 0
var longest_streak: int = 0
var correct_words: int = 0

# Typing tracking
var active_typing_time: float = 0.0
var is_typing: bool = false
var typing_timeout: float = 0.5
var typing_timer: float = 0.0

@onready var player = $Player
@onready var spawn_timer = $SpawnTimer
@onready var enemy_container = $EnemyContainer
@onready var ui_layer = $UI
@onready var score_label: Label = $UI/ScoreLabel
@onready var mistakes_label: Label = $UI/MistakesLabel
@onready var level_label: Label = $UI/LevelLabel
@onready var camera: Camera2D = $Camera2D

var current_enemy_speed = 170
var base_level_threshold: int = 1000
var enemy_scene = preload("res://scenes/enemy.tscn")
var laser_scene = preload("res://scenes/laser.tscn")
var tank_enemy_scene = preload("res://scenes/tank_enemy.tscn")
var tank_present = false
var tank_spawned_this_level = false

func _ready():
	randomize()
	load_words()
	mech_sound("play")
	start_time = Time.get_unix_time_from_system()
	if word_list.size() > 0:
		next_word = word_list[randi() % word_list.size()]
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	player.shoot_laser.connect(_on_player_shoot)
	player.player_hit.connect(_on_player_hit)
	spawn_timer.start()
	AudioManager.background_music.play()
	
	
func mech_sound(action) -> void:
	if action == "play":
		AudioManager.mech_step.pitch_scale = randf_range(1.1, 1.3)
		AudioManager.mech_step.play()
		await get_tree().create_timer(0.9).timeout
		AudioManager.mech_step.pitch_scale = randf_range(1.1, 1.3)
		AudioManager.mech_step.play()
	else: AudioManager.mech_step.stop()

func _process(delta: float) -> void:
	if is_typing:
		active_typing_time += delta
		typing_timer += delta
		if typing_timer > typing_timeout:
			is_typing = false
			
			
func shake_camera(intensity: float = 10.0, duration: float = 0.4) -> void:
	var original_position = camera.position
	var tween = create_tween()
	
	for i in range(int(duration / 0.05)):
		# Create random offset
		var offset = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		
		# Tween to offset
		tween.tween_property(camera, "position", original_position + offset, 0.05)
	
	# Final tween back to original position
	tween.tween_property(camera, "position", original_position, 0.05)

func _input(event):
	if not game_active:
		return
		
	if event is InputEventKey and event.pressed:
		total_chars_typed += 1
		is_typing = true
		typing_timer = 0.0
		AudioManager.type.pitch_scale = randf_range(0.85, 1.1)
		AudioManager.type.play()
		check_typed_letter(char(event.keycode).to_lower())

func check_typed_letter(letter: String):
	var enemies = enemy_container.get_children()
	for enemy in enemies:
		if not enemy.current_letters.is_empty() and enemy.current_letters[0] == letter:
			var first_letter_scene = enemy.letter_scenes[0]
			if is_instance_valid(first_letter_scene):
				update_score(10)
				AudioManager.correct_letter.pitch_scale = randf_range(0.9, 1.1)
				AudioManager.correct_letter.play()
				correct_chars += 1
				current_streak += 1
				longest_streak = max(current_streak, longest_streak)
				player.shoot(first_letter_scene.global_position)
				enemy.destroy_letter(letter)
				return
				
	AudioManager.wrong_letter.play()
	wrong_chars += 1
	player.take_damage()
	current_streak = 0
	update_mistakes_ui()
	
	if wrong_chars >= MAX_WRONG_LETTERS && game_active:
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

func update_score(amount: int) -> void:
	score += amount
	score_label.text = "Score: %d" % score
	
	# Instead of computing new_level from score directly,
	# we check if score meets the threshold for the next level.
	if score >= get_required_score_for_level(current_level + 1) and tank_spawned_this_level and not tank_present:
		current_level += 1
		# Reset the tank flag so that a new tank can be spawned in the new level.
		tank_spawned_this_level = false
		animate_level_label()
		AudioManager.next_level.play()
		level_label.text = "Level: %d" % current_level
		
		var new_speed = 80 + (current_level - 1) * 10
		if new_speed > current_enemy_speed:
			current_enemy_speed = new_speed
			update_enemy_speeds()
			
func get_required_score_for_level(level: int) -> int:
	# Using an exponent of 1.5 gives a slower increase.
	# This is equivalent to: base_level_threshold * level * sqrt(level)
	return int(base_level_threshold * pow(level, 1.2))

func animate_level_label():
	level_label.pivot_offset = level_label.size / 2
	
	var main_tween = create_tween()
	main_tween.set_parallel(true)
	
	var original_pos = level_label.position
	var original_rotation = level_label.rotation
	
	main_tween.tween_property(level_label, "modulate", Color(0, 0.5, 1), 0.5)
	main_tween.tween_property(level_label, "modulate", Color.WHITE, 0.3)\
		.set_delay(1)
	
	main_tween.tween_property(level_label, "scale", Vector2(1.1, 1.1), 0.2)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
	main_tween.tween_property(level_label, "scale", Vector2(1, 1), 0.2)\
		.set_trans(Tween.TRANS_BOUNCE)\
		.set_ease(Tween.EASE_OUT)\
		.set_delay(0.3)
	
	var shake_tween = create_tween()
	shake_tween.set_parallel(false)
	
	var shake_strength = 3.0
	var shake_duration = 0.03
	var num_shakes = 7
	var rotation_strength = 0.05
	
	for i in range(num_shakes):
		var random_offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
		var random_rotation = randf_range(-rotation_strength, rotation_strength)
		
		var shake_group = create_tween()
		shake_group.set_parallel(true)
		
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
		
		await shake_group.finished
	
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
		enemy.set_speed(current_enemy_speed)

func _on_spawn_timer_timeout():
	spawn_enemy()

func spawn_enemy():
	if tank_present:
		return

	# Calculate the points remaining until the next level.
	var points_to_next_level = get_required_score_for_level(current_level + 1) - score

	# When we're close enough to leveling up, spawn a tank enemy if one hasn't been spawned yet.
	if (points_to_next_level <= 150) and (not tank_spawned_this_level):
		spawn_tank_enemy()
		tank_spawned_this_level = true
		return

	spawn_regular_enemy()

func get_random_tank_word() -> String:
	if word_list.is_empty():
		return ""
	while true:
		var candidate = word_list[randi() % word_list.size()]
		if candidate.length() >= 5:
			return candidate
	return ""

func spawn_tank_enemy():
	var enemy = tank_enemy_scene.instantiate()
	enemy.set_speed(current_enemy_speed * 0.7)
	var tank_words = []
	for i in range(3):
		tank_words.append(get_random_tank_word())
	enemy.word = "\n".join(tank_words)
	enemy.position = Vector2(1800, 770)
	enemy_container.add_child(enemy)
	AudioManager.tank_sound.play()
	enemy.enemy_died.connect(_on_tank_died)
	tank_present = true
	spawn_timer.stop()

func spawn_regular_enemy():
	var enemy = enemy_scene.instantiate()
	enemy.speed = current_enemy_speed
	print("Speed", enemy.speed)
	enemy.word = next_word
	enemy.position = Vector2(1700, 770)
	enemy_container.add_child(enemy)
	enemy.enemy_died.connect(_on_enemy_died)
	
	next_word = word_list[randi() % word_list.size()]
	
	var letter_width: float = 42.0
	var desired_gap: float = 40.0
	var current_word_width = enemy.word.length() * letter_width
	var next_word_width = next_word.length() * letter_width
	var distance: float = current_word_width / 2.0 + desired_gap + next_word_width / 2.0
	var delay: float = distance / enemy.speed
	spawn_timer.wait_time = delay
	spawn_timer.start()

func _on_tank_died():
	shake_camera(8.0, 0.8)
	AudioManager.tank_sound.stop()
	tank_present = false
	update_score(150)
	correct_words += 3
	spawn_timer.start()

func _on_enemy_died():
	shake_camera(2.0, 0.2)
	update_score(50)
	correct_words += 1
	
func _on_player_shoot(start_pos: Vector2, target_pos: Vector2):
	var laser = laser_scene.instantiate()
	add_child(laser)
	laser.shoot(start_pos, target_pos)

func _on_player_hit():
	game_over()

func game_over():
	AudioManager.player_die.play()
	player.die()
	AudioManager.tank_sound.stop()
	AudioManager.game_over.play()
	game_active = false
	spawn_timer.stop()
	show_game_over_screen()

func update_mistakes_ui():
	mistakes_label.text = "Mistakes: %d" % wrong_chars

func show_game_over_screen():
	if not show_game_over:
		show_game_over = true
		await get_tree().create_timer(1.0).timeout
		
		var time_played = Time.get_unix_time_from_system() - start_time
		var accuracy = (float(correct_chars) / total_chars_typed * 100) if total_chars_typed > 0 else 0.0
		var wpm = (correct_chars / 5.0) / (active_typing_time / 60.0) if active_typing_time > 0 else 0.0
		
		var game_over_screen = preload("res://scenes/game_over.tscn").instantiate()
		game_over_screen.initialize_stats({
			"score": score,
			"level": current_level,
			"time_played": time_played,
			"correct_words": correct_words,
			"total_chars": total_chars_typed,
			"correct_chars": correct_chars,
			"accuracy": accuracy,
			"longest_streak": longest_streak,
			"wpm": wpm
		})
		
		get_tree().get_root().add_child(game_over_screen)
		ui_layer.hide()
