extends Node2D

var lives: int = 6
var max_lives: int = 6

var word_list = [] 
var game_active = true
var current_level = 1
var next_word: String = ""
var show_game_over = false

var required_enemies_for_boss: int = 15

# Statistics variables
var score = 0
var start_time: int
var correct_chars: int = 0
var total_chars_typed: int = 0
var wrong_chars: int = 0
var current_streak: int = 0
var longest_streak: int = 0
var correct_words: int = 0
var correct_words_this_level: int = 0
var is_current_word_correct: bool = true

# Typing tracking
var active_typing_time: float = 0.0
var is_typing: bool = false
var typing_timeout: float = 0.3
var typing_timer: float = 0.0

var wrong_chars_this_level: int = 0

var displayed_score: int = 0
var score_tween: Tween = null

@onready var player = $Player
@onready var spawn_timer = $SpawnTimer
@onready var enemy_container = $EnemyContainer
@onready var ui_layer = $UI
@onready var score_label: Label = $UI/ScoreLabel
@onready var level_label: Label = $UI/LevelLabel
@onready var camera: Camera2D = $Camera2D
@onready var lives_container: HBoxContainer = $UI/LivesContainer
@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var distortion_shader: ColorRect = $DistortionShader/DistortionShader
@onready var achievement_label: Label = $UI/AchievementsContainer/AchievementLabel
@onready var achievement_badge: TextureRect = $UI/AchievementsContainer/AchievementBadge
@onready var debug_label: Label = $UI/DebugLabel
@onready var achievement_animation: AnimationPlayer = $UI/AchievementAnimation


var current_enemy_speed: int
var base_level_threshold: int = 1000
var enemy_scene = preload("res://scenes/enemy.tscn")
var laser_scene = preload("res://scenes/laser.tscn")
var tank_enemy_scene = preload("res://scenes/tank_enemy.tscn")
var small_enemy_scene = preload("res://scenes/small_enemy.tscn")
var robot_enemy_scene = preload("res://scenes/robot_enemy.tscn")
var ship_enemy_scene = preload("res://scenes/ship_enemy.tscn")
var heart_icon = preload("res://scenes/heart_icon.tscn") 
var tank_present = false
var tank_spawned_this_level = false

var is_paused = false

# ============================================================================
# PLAYTIME TRACKING (only counts when game is active and not paused)
# ============================================================================
var active_playtime: float = 0.0
var playtime_timer: float = 0.0
# Update Achievements stat every 1 second of active gameplay:
var playtime_update_interval: float = 1.0

func update_debug_text():
	var persistent_text = """
📊 **PERSISTENT STATS**
-------------------
🕒 Total Playtime: %d sec
⌨️ Total Words Typed: %d
🔥 Longest Streak: %d
🎯 Overall Accuracy: %.1f%%
🏆 Bosses Defeated: %d
🚀 Highest Level: %d
💀 Total Deaths: %d
👹 Enemies Defeated: %d
✅ Perfect Levels: %d
💪 Comebacks: %d
""" % [
		Achievements.stats["total_playtime"],
		Achievements.stats["total_words_typed"],
		Achievements.stats["longest_streak"],
		Achievements.stats["overall_accuracy"],
		Achievements.stats["bosses_defeated"],
		Achievements.stats["highest_level"],
		Achievements.stats["total_deaths"],
		Achievements.stats["enemies_defeated"],
		Achievements.stats["perfect_levels_count"],
		Achievements.stats["comebacks_count"]
	]
	
	var run_text = """
🏃 **RUN STATS**
-------------------
🏁 Words Typed This Run: %d
🔥 Bosses Defeated This Run: %d
""" % [
		Achievements.run_stats["total_words_typed"],
		Achievements.run_stats["bosses_defeated"]
	]
	
	var achievement_text = "----- Unlocked Achievements -----\n"
	for achievement_id in Achievements.ACHIEVEMENTS.keys():
		if Achievements.is_unlocked(achievement_id):
			var achievement = Achievements.ACHIEVEMENTS[achievement_id]
			achievement_text += "✨ " + achievement.title + "\n"
	for achievement_id in Achievements.RUN_ACHIEVEMENTS.keys():
		if Achievements.is_unlocked(achievement_id):
			var achievement = Achievements.RUN_ACHIEVEMENTS[achievement_id]
			achievement_text += "✨ " + achievement.title + "\n"
	if achievement_text == "----- Unlocked Achievements -----\n":
		achievement_text += "None yet!\n"
		
	debug_label.text = persistent_text + "\n" + run_text + "\n" + achievement_text


var achievement_queue: Array = []
var is_playing_achievement = false

func _on_achievement_unlocked(achievement_id: String) -> void:
	print("Achievement queued:", achievement_id)  # Log each queued achievement
	achievement_queue.append(achievement_id)
	
	# If an animation is NOT currently playing, start processing the queue
	if not is_playing_achievement:
		print("Starting achievement queue processing")
		process_achievement_queue()
	else:
		print("Achievement queued, waiting for current animation to finish.")

func process_achievement_queue():
	if achievement_queue.is_empty():
		is_playing_achievement = false
		return
	
	is_playing_achievement = true
	var achievement_id = achievement_queue.pop_front()

	var achievement_data: Dictionary
	if Achievements.ACHIEVEMENTS.has(achievement_id):
		achievement_data = Achievements.ACHIEVEMENTS[achievement_id]
	elif Achievements.RUN_ACHIEVEMENTS.has(achievement_id):
		achievement_data = Achievements.RUN_ACHIEVEMENTS[achievement_id]
	else:
		achievement_data = {"title": achievement_id, "description": ""}

	achievement_label.text = "Achievement Unlocked: " + achievement_data.title
	achievement_badge.texture = Achievements.get_badge_texture(achievement_id)
	
	achievement_animation.stop()  # Stop any previous animation
	achievement_animation.seek(0, true)  # Reset animation to start
	achievement_animation.play("achievement_appear")
	
	print("Playing achievement sound")
	AudioManager.achievement.play()
	await AudioManager.achievement.finished
	print("Achievement sound finished for:", achievement_data.title)

	if achievement_data.has("voice_file"):
		var voice_stream = load(achievement_data.voice_file) as AudioStream
		if voice_stream:
			AudioManager.achievement_voice.stream = voice_stream
			AudioManager.achievement_voice.play()
			await AudioManager.achievement_voice.finished

	await achievement_animation.animation_finished

	await get_tree().create_timer(0.3).timeout
	
	process_achievement_queue()


func _ready():
	Achievements.connect("achievement_unlocked", _on_achievement_unlocked)
	achievement_badge.texture = load(Achievements.DEFAULT_BADGE) as Texture2D
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	renderDistortionShader()
	tank_present = false
	randomize()
	load_words()
	mech_sound("play")
	required_enemies_for_boss = 15
	camera = get_node_or_null("Camera2D")
	current_enemy_speed = GameSettings.enemy_speed
	start_time = Time.get_unix_time_from_system()
	if word_list.size() > 0:
		next_word = word_list[randi() % word_list.size()]
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	player.shoot_laser.connect(_on_player_shoot)
	player.player_hit.connect(_on_player_hit)
	spawn_timer.start()
	setup_lives_display()
	Achievements.reset_run_stats()
	
func setup_lives_display():
	# Clear any existing hearts
	for child in lives_container.get_children():
		child.queue_free()
	
	# Add heart icons for each life
	for i in range(max_lives):
		var heart = heart_icon.instantiate()
		lives_container.add_child(heart)
	
	update_lives_display()

func update_lives_display():
	var heart_icons = lives_container.get_children()
	for i in range(heart_icons.size()):
		heart_icons[i].modulate = Color.WHITE if i < lives else Color(0.2, 0.2, 0.2)

func reset_lives():
	lives = max_lives
	AudioManager.heart_beat.stop()
	wrong_chars_this_level = 0
	update_lives_display()
	
	
func mech_sound(action) -> void:
	if not is_instance_valid(AudioManager):
		return
	if action == "play":
		if AudioManager.mech_step:
			AudioManager.mech_step.pitch_scale = randf_range(1.1, 1.3)
			AudioManager.mech_step.play()
			await get_tree().create_timer(0.9).timeout
			if is_instance_valid(AudioManager) and AudioManager.mech_step:
				AudioManager.mech_step.pitch_scale = randf_range(1.1, 1.3)
				AudioManager.mech_step.play()
	else: 
		if AudioManager.mech_step:
			AudioManager.mech_step.stop()

func _process(delta: float) -> void:
	# Only count playtime when game is active and not paused.
	if game_active and not get_tree().paused:
		active_playtime += delta
		playtime_timer += delta
		# Update Achievements stat every playtime_update_interval seconds.
		if playtime_timer >= playtime_update_interval:
			# Increment the total playtime stat by the amount accumulated.
			Achievements.update_stat("total_playtime", playtime_timer)
			playtime_timer = 0.0
	
	if is_typing:
		active_typing_time += delta
		typing_timer += delta
		if typing_timer > typing_timeout:
			is_typing = false
	update_debug_text()
			
			
func shake_camera(intensity: float = 10.0, duration: float = 0.4) -> void:
	var original_position = camera.position
	var tween = create_tween()
	for i in range(int(duration / 0.05)):
		# Create random offset
		var offset = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		
		tween.tween_property(camera, "position", original_position + offset, 0.05)
	
	tween.tween_property(camera, "position", original_position, 0.05)
	
func renderDistortionShader() -> void:
	distortion_shader.visible = true
	var tween = create_tween()
	tween.tween_property(distortion_shader, "material:shader_parameter/radius", 1, 0.5)
	await tween.finished
	var return_tween = create_tween()
	return_tween.tween_property(distortion_shader.material, "shader_parameter/radius", 0, 0)
	await return_tween.finished
	distortion_shader.visible = false

func _input(event: InputEvent) -> void:
	
	if event is InputEventKey and event.pressed and event.keycode == KEY_1:
		debug_label.visible = not debug_label.visible
		
	if event is InputEventKey and event.pressed and event.keycode == KEY_2:
		renderDistortionShader()

	if not game_active:
		return
		
	if event.is_action_pressed("ui_cancel"):  # ESC key
		toggle_pause()
		
	if event is InputEventKey and event.pressed:
		# Only handle letter keys (A-Z)
		var keycode = event.keycode
		if keycode >= KEY_A and keycode <= KEY_Z:
			total_chars_typed += 1
			if not is_typing:
				is_typing = true
				typing_timer = 0.0
			
			if is_instance_valid(AudioManager) and AudioManager.type:
				AudioManager.type.pitch_scale = randf_range(0.85, 1.1)
				AudioManager.type.play()
				
			check_typed_letter(char(keycode).to_lower())
			
func toggle_pause():
	is_paused = !is_paused

	var time_played = Time.get_unix_time_from_system() - start_time
	var accuracy = (float(correct_chars) / total_chars_typed * 100) if total_chars_typed > 0 else 0.0
	var wpm = (correct_chars / 5.0) / (active_typing_time / 60.0) if active_typing_time > 0 else 0.0

	var pause_menu = preload("res://scenes/pause_menu.tscn").instantiate()
	pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS

	var main_node = get_node("/root/Main")

	# Find the index of CrtShader manually
	var crt_shader_index = -1
	for i in range(main_node.get_child_count()):
		if main_node.get_child(i) == $CrtShader:
			crt_shader_index = i
			break

	# If CrtShader exists, insert pause_menu above it; otherwise, just add at the end
	main_node.add_child(pause_menu)
	if crt_shader_index > 0:
		main_node.move_child(pause_menu, crt_shader_index)

	get_tree().paused = true


		
func check_typed_letter(letter: String):
	var enemies = enemy_container.get_children()
	if enemies.is_empty():
		return

	var valid_enemy = null
	for enemy in enemies:
		if not enemy.is_dying:
			valid_enemy = enemy
			break

	# If no enemy is available (they are all dying), you can choose to simply ignore the input.
	if valid_enemy == null:
		return

	if not valid_enemy.current_letters.is_empty() and valid_enemy.current_letters[0] == letter:
		var first_letter_scene = valid_enemy.letter_scenes[0]
		if is_instance_valid(first_letter_scene):
			update_score(10)
			AudioManager.correct_letter.pitch_scale = randf_range(0.9, 1.1)
			AudioManager.correct_letter.play()
			correct_chars += 1
			player.shoot(first_letter_scene.global_position)
			valid_enemy.destroy_letter(letter)
			if valid_enemy.current_letters.is_empty():
				Achievements.update_stat("total_words_typed", 1)
				if is_current_word_correct:
					current_streak += 1
					longest_streak = max(longest_streak, current_streak)
					Achievements.set_stat("longest_streak", longest_streak)
				is_current_word_correct = true
			return
			
	valid_enemy.flash_letter()
	AudioManager.wrong_letter.play()
	wrong_chars += 1
	wrong_chars_this_level += 1
	player.take_damage()
	is_current_word_correct = false
	current_streak = 0
	lives -= 1
	update_lives_display()
	if lives == 1: AudioManager.heart_beat.play()
	else: AudioManager.heart_beat.stop()
	
	if lives <= 0 and game_active:
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
		
func calculate_difficulty_multiplier() -> float:
	match GameSettings.enemy_speed:
		30:  return 0.5  # Beginner
		80:  return 1.0  # Casual
		180: return 1.5  # Challenging
		230: return 2.0  # Expert
		400: return 3.0  # Insane
		_:   return 1.0  # Default case

func calculate_streak_multiplier() -> float:
	if current_streak <= 2:
		return 1.0
	elif current_streak <= 5:
		return 1.5
	elif current_streak <= 10:
		return 2.0
	elif current_streak <= 20:
		return 3.0
	else:
		return 4.0 

func update_score(amount: int) -> void:
	var difficulty_multiplier = calculate_difficulty_multiplier()
	var streak_multiplier = calculate_streak_multiplier()
	var final_amount = int(amount * difficulty_multiplier * streak_multiplier)
	var previous_score = score  # Store the current score before adding new amount
	score += final_amount
	
	if score_tween and score_tween.is_valid():
		score_tween.kill()
	
	# Create a new tween
	score_tween = create_tween()
	# Animate from previous_score to new score
	score_tween.tween_method(
		func(value): 
			displayed_score = value
			score_label.text = "Score: %d" % displayed_score,
		previous_score,  # Start from previous score
		score,          # End at new score
		0.5            # 0.5s duration
	)
	
	show_floating_score(final_amount)
			
var floating_scores := [] 
var score_font: Font = preload("res://assets/fonts/DepartureMonoNerdFont-Regular.otf")

const MAX_FLOATING_SCORES = 5

func show_floating_score(amount: int) -> void:
	# If we already have MAX_FLOATING_SCORES labels, remove the oldest one first
	if floating_scores.size() >= MAX_FLOATING_SCORES:
		var oldest_label = floating_scores.pop_front()
		oldest_label.queue_free()
	
	var floating_label = Label.new()
	floating_label.text = "+%d" % amount
	floating_label.add_theme_color_override("font_color", Color.MAGENTA)  
	floating_label.add_theme_font_size_override("font_size", 20)
	floating_label.add_theme_font_override("font", score_font)
	var score_position = score_label.global_position
	var base_y = score_position.y + 40
	# Calculate offset based on current number of scores (max 4 since we're adding one)
	var offset_y = floating_scores.size() * 20
	floating_label.position = Vector2(score_position.x + score_label.size.x / 2 + 30, base_y + offset_y)
	ui_layer.add_child(floating_label)
	floating_scores.append(floating_label)
	
	if floating_scores.size() == 1:
		remove_oldest_score()
		
func schedule_score_removal():
	await get_tree().create_timer(0.03).timeout 
	if floating_scores.is_empty():
		return
	remove_oldest_score()
	
func remove_oldest_score():
	if floating_scores.is_empty():
		return
	await get_tree().create_timer(0.03).timeout

	if floating_scores.is_empty():
		return
	var oldest_label = floating_scores.pop_front()  
	var remove_tween = create_tween()
	remove_tween.tween_property(oldest_label, "modulate:a", 0.0, 0.1) 
	remove_tween.tween_property(oldest_label, "position:y", score_label.global_position.y, 0.1)  # Move into the score label
	await remove_tween.finished

	if is_instance_valid(oldest_label):
		oldest_label.queue_free()

	move_scores_up()

	if not floating_scores.is_empty():
		remove_oldest_score()

func move_scores_up():
	if floating_scores.is_empty():
		return
	var tween = create_tween()
	tween.set_parallel(true)
	var score_position = score_label.global_position
	var base_y = score_position.y + 30  
	for i in range(floating_scores.size()):
		var target_label = floating_scores[i]
		var new_y = base_y + (i * 20) - 20
		tween.tween_property(target_label, "position:y", new_y, 0.05).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

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
		
	if correct_words_this_level >= required_enemies_for_boss and not tank_spawned_this_level:
		var random_value = randf()
		if random_value < 0.7:
			spawn_tank_enemy()
		else:
			spawn_ship_enemy()
		tank_spawned_this_level = true
		return
		
	spawn_regular_enemy()

func get_random_long_word() -> String:
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
		tank_words.append(get_random_long_word())
	enemy.word = "\n".join(tank_words)
	enemy.position = Vector2(2000, 770)
	enemy_container.add_child(enemy)
	AudioManager.tank_sound.play()
	AudioManager.boss.play()
	enemy.enemy_died.connect(_on_tank_died)
	tank_present = true
	spawn_timer.stop()
	
func spawn_ship_enemy():
	var enemy = ship_enemy_scene.instantiate()
	enemy.set_speed(current_enemy_speed * 0.6)
	var ship_words = []
	for i in range(4):
		ship_words.append(get_random_long_word())
	enemy.word = "\n".join(ship_words)
	enemy.position = Vector2(2000, 700)
	enemy_container.add_child(enemy)
	AudioManager.space_ship.play()
	AudioManager.boss.play()
	enemy.enemy_died.connect(_on_tank_died)
	tank_present = true
	spawn_timer.stop()

func spawn_regular_enemy():
	var enemy
	if next_word.length() <= 3:
		enemy = small_enemy_scene.instantiate()
	elif next_word.length() == 4:
		enemy = robot_enemy_scene.instantiate()
	else:
		enemy = enemy_scene.instantiate()
		
	enemy.speed = current_enemy_speed
	enemy.word = next_word
	enemy.position = Vector2(1800, 770)
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
	Achievements.update_stat("bosses_defeated", 1)
	AudioManager.tank_sound.stop()
	AudioManager.space_ship.stop()
	AudioManager.boss.stop()
	AudioManager.explosion.play()
	shake_camera(8.0, 0.8)
	renderDistortionShader()
	tank_present = false
	update_score(150)
	if is_current_word_correct:
		current_streak += 3
		longest_streak = max(longest_streak, current_streak)
	
	is_current_word_correct = true
	correct_words += 3
	
	correct_words_this_level = 0
	current_level += 1
	Achievements.set_stat("highest_level", current_level)
	if lives == 1: Achievements.update_stat("comebacks_count", 1)
	if wrong_chars_this_level == 0: Achievements.update_stat("perfect_levels_count", 1)
	tank_spawned_this_level = false
	required_enemies_for_boss = 15 + (current_level - 1) * 3  # Increase requirement for next boss
	animate_level_label()
	AudioManager.next_level.play()
	level_label.text = "Level: %d" % current_level
	reset_lives()
	
	# Update enemy speed
	var new_speed = 80 + (current_level - 1) * 7
	if new_speed > current_enemy_speed:
		current_enemy_speed = new_speed
		update_enemy_speeds()
	
	spawn_timer.start()

func _on_enemy_died():
	Achievements.update_stat("enemies_defeated", 1)
	update_debug_text()
	show_streak_label()
	shake_camera(2.0, 0.2)
	update_score(50)
	correct_words += 1
	correct_words_this_level += 1
	
var streak_labels = []
var custom_font = preload("res://assets/fonts/DepartureMonoNerdFont-Regular.otf")

func show_streak_label():
	if current_streak <= 0:
		return 
	var streak_label = RichTextLabel.new()
	streak_label.bbcode_enabled = true
	streak_label.scroll_active = false
	streak_label.fit_content = true
	streak_label.clip_contents = false
	streak_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	streak_label.custom_minimum_size = Vector2(500, 100)
	
	var viewport_size = get_viewport_rect().size
	streak_label.position = Vector2(
		viewport_size.x / 2,
		(viewport_size.y / 2) - 300
	)
	
	streak_label.add_theme_font_override("normal_font", custom_font)
	
	var progress = clamp(float(current_streak - 1) / 19.0, 0.0, 1.0)
	var font_size = int(lerp(32, 64, progress))
	var color_progress = int(255 * (1.0 - progress))
	var interpolated_color = "#ff%02x%02x" % [color_progress, 255]
	
	var formatted_text = "[center][font_size=%d][color=%s]" % [font_size, interpolated_color]
	
	if current_streak >= 25:
		if current_streak == 25: AudioManager.mega_streak.play()
		formatted_text += "[shake rate=20.0 level=5][wave amp=10.0 freq=2.0][rainbow freq=1.5 sat=0.9 val=1.0]"
		formatted_text += "STREAK x %d" % current_streak
		formatted_text += "[/rainbow][/wave][/shake]"
		
	elif current_streak >= 10:
		formatted_text += "[shake rate=20.0 level=5][wave amp=10.0 freq=2.0]"
		formatted_text += "STREAK x %d" % current_streak
		formatted_text += "[/wave][/shake]"
	
	elif current_streak >= 5:
		formatted_text += "[shake rate=20.0 level=5]"
		formatted_text += "STREAK x %d" % current_streak
		formatted_text += "[/shake]"
	
	else:
		formatted_text += "STREAK x %d" % current_streak
		
	formatted_text += "[/color][/font_size][/center]"
	streak_label.text = formatted_text
	
	var base_pitch = 1.0
	var max_pitch_increase = 1.5  # Maximum increase above base pitch
	var steps = 30.0  # Number of steps to reach maximum
	var pitch_increase = min((current_streak / steps) * max_pitch_increase, max_pitch_increase)
	AudioManager.streak.pitch_scale = base_pitch + pitch_increase
	AudioManager.streak.play()
	
	get_parent().add_child(streak_label)
	streak_label.position.x -= streak_label.size.x / 2
	var tween = create_tween()
	tween.tween_property(streak_label, "modulate:a", 0.0, 0.3).set_delay(0.5)
	await tween.finished
	streak_label.queue_free()

	
func _on_player_shoot(start_pos: Vector2, target_pos: Vector2):
	var laser = laser_scene.instantiate()
	add_child(laser)
	laser.shoot(start_pos, target_pos)

func _on_player_hit():
	game_over()

func game_over():
	Achievements.update_stat("total_deaths", 1)
	player.die()
	shake_camera(25.0, 0.6)
	if world_environment.environment:
		var tween = get_tree().create_tween()
		tween.tween_property(world_environment.environment, "adjustment_saturation", 0, 0.2)
		tween.tween_property(world_environment.environment, "adjustment_saturation", 1, 0.4)
	AudioManager.player_die.play()
	AudioManager.tank_sound.stop()
	AudioManager.boss.stop()
	AudioManager.heart_beat.stop()
	AudioManager.space_ship.stop()
	AudioManager.game_over.play()
	mech_sound("stop")
	game_active = false
	spawn_timer.stop()
	
	for enemy in enemy_container.get_children():
		enemy.queue_free()
	show_game_over_screen()

func show_game_over_screen():
	if not show_game_over:
		show_game_over = true
		await get_tree().create_timer(1.0).timeout
		
		var accuracy = (float(correct_chars) / total_chars_typed * 100) if total_chars_typed > 0 else 0.0
		var wpm = (correct_chars / 5.0) / (active_typing_time / 60.0) if active_typing_time > 0 else 0.0
		
		var game_over_screen = preload("res://scenes/game_over.tscn").instantiate()
		game_over_screen.initialize_stats({
			"score": score,
			"level": current_level,
			"time_played": active_playtime,
			"correct_words": correct_words,
			"total_chars": total_chars_typed,
			"correct_chars": correct_chars,
			"accuracy": accuracy,
			"longest_streak": longest_streak,
			"wpm": wpm
		})
		
		get_tree().get_root().add_child(game_over_screen)
		ui_layer.hide()
