# GameOverScreen.gd
extends Control

@onready var high_score_label: Label = $Panel2/VBoxContainer/HighScoreLabel
@onready var time_played_label: Label = $Panel2/VBoxContainer/TimePlayedLabel
@onready var correct_words_label: Label = $Panel2/VBoxContainer/CorrectWordsLabel
@onready var accuracy_label: Label =$Panel2/VBoxContainer/AccuracyLabel
@onready var longest_streak_label: Label = $Panel2/VBoxContainer/LongestStreakLabel
@onready var wpm_label: Label = $Panel2/VBoxContainer/WPMLabel
@onready var level_label: Label = $Panel2/VBoxContainer/LevelLabel
@onready var difficulty_select: OptionButton = $DifficultySelect
@onready var panel: Panel = $Panel2
@onready var restart_button: FancyButton = $RestartButton

var can_restart: bool = false

var stats: Dictionary

# --- Animated properties with setters ---

var _display_score: int = 0
var display_score: int:
	get:
		return _display_score
	set(value):
		_display_score = value
		high_score_label.text = "%d" % _display_score

var _display_level: int = 0
var display_level: int:
	get:
		return _display_level
	set(value):
		_display_level = value
		level_label.text = "%d" % _display_level

var _display_time: int = 0
var display_time: int:
	get:
		return _display_time
	set(value):
		_display_time = value
		time_played_label.text = "%d seconds" % _display_time

var _display_correct_words: int = 0
var display_correct_words: int:
	get:
		return _display_correct_words
	set(value):
		_display_correct_words = value
		correct_words_label.text = "%d" % _display_correct_words

var _display_accuracy: float = 0.0
var display_accuracy: float:
	get:
		return _display_accuracy
	set(value):
		_display_accuracy = value
		# Here we assume stats.correct_chars and stats.total_chars are available.
		if stats.has("correct_chars") and stats.has("total_chars"):
			accuracy_label.text = "%d / %d (%.1f%%)" % [ stats.correct_chars, stats.total_chars, _display_accuracy ]
		else:
			accuracy_label.text = "%.1f%%" % _display_accuracy

var _display_longest_streak: int = 0
var display_longest_streak: int:
	get:
		return _display_longest_streak
	set(value):
		_display_longest_streak = value
		longest_streak_label.text = "%d words" % _display_longest_streak

var _display_wpm: float = 0.0
var display_wpm: float:
	get:
		return _display_wpm
	set(value):
		_display_wpm = value
		wpm_label.text = "%.1f" % _display_wpm

# --- End of animated properties ---

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if not high_score_label:
		print("HighScoreLabel not found!")
	if not level_label:
		print("LevelLabel not found!")
	for i in range(difficulty_select.item_count):
		if difficulty_select.get_item_id(i) == GameSettings.enemy_speed:
			difficulty_select.selected = i
			break  # Stop the loop once the correct item is found

func initialize_stats(game_stats: Dictionary) -> void:
	stats = game_stats
	# Wait until we're in the scene tree before updating the UI.
	if is_inside_tree():
		update_ui()
	else:
		await ready
		update_ui()

func update_ui() -> void:
	# Reset all displayed values to 0.
	display_score = 0
	display_level = 0
	display_time = 0
	display_correct_words = 0
	display_accuracy = 0.0
	display_longest_streak = 0
	display_wpm = 0.0
	
	await get_tree().create_timer(1.4).timeout
	


	await animate_stat(high_score_label, "display_score", stats.score, 0.4)
	if stats.score > Achievements.stats["high_score"]:
		Achievements.set_stat("high_score", stats.score)
		var voice_stream = load("res://assets/sounds/achievements/new_highscore.mp3") as AudioStream
		if voice_stream:
			AudioManager.achievement_voice.stream = voice_stream
			AudioManager.achievement_voice.play()
		start_highscore_pulsate()
	can_restart = true
	await animate_stat(level_label, "display_level", stats.level, 0.2)
	await animate_stat(time_played_label, "display_time", stats.time_played, 0.2)
	await animate_stat(correct_words_label, "display_correct_words", stats.correct_words, 0.2)
	await animate_stat(accuracy_label, "display_accuracy", stats.accuracy, 0.2)
	await animate_stat(longest_streak_label, "display_longest_streak", stats.longest_streak, 0.2)
	await animate_stat(wpm_label, "display_wpm", stats.wpm, 0.2)
	restart_button.grab_focus()
	
func start_highscore_pulsate() -> void:

	high_score_label.add_theme_color_override("font_color", Color(1.2, 0, 1.2, 1))  # Bright magenta
	high_score_label.add_theme_constant_override("outline_size", 2)
	high_score_label.add_theme_color_override("font_outline_color", Color(1.2, 0, 1.2, 0.6))
	
	var glow_tween = create_tween()
	glow_tween.set_loops()
	
	glow_tween.tween_property(high_score_label, "modulate", 
		Color(1.2, 0, 1.2, 1), 0.5)\
		.set_trans(Tween.TRANS_SINE)
	glow_tween.tween_property(high_score_label, "modulate", 
		Color(0.8, 0, 0.8, 0.8), 0.5)\
		.set_trans(Tween.TRANS_SINE)

func animate_stat(label: Control, property_name: String, target_value: float, duration: float) -> void:
	var tween = create_tween()
	tween.tween_property(self, property_name, target_value, duration).set_trans(Tween.TRANS_LINEAR)
	await tween.finished
	await shake_label(label)
	
func shake_label(label: Control) -> void:
	AudioManager.click.pitch_scale = randf_range(0.95, 1.05)
	AudioManager.click.play()
	var original_position = label.position
	var original_panel_position = panel.position
	var original_color = label.modulate
	var tween = create_tween()
	tween.tween_property(label, "position:x", original_position.x + 15, 0.05).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(label, "modulate", Color.MAGENTA, 0.05).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(label, "position:x", original_position.x, 0.05).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(label, "modulate", original_color, 0.05).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(panel, "position:x", original_panel_position.x - 10, 0.1).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(panel, "position:x", original_panel_position.x, 0.05).set_trans(Tween.TRANS_BOUNCE)

	await tween.finished  


func _input(event: InputEvent) -> void:
	if not can_restart:  # Ignore input if animations aren't done
		return
		
	# Only handle space or enter key for restart
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
			restart_game()

func restart_game() -> void:
	can_restart = false
	var root = get_tree().root
	
	var current_main = root.get_node_or_null("Main")
	if current_main:
		current_main.free()
	
	for child in root.get_children():
		if child.name.begins_with("@") or child == self or child.name == "AudioManager" or child.name == "GameSettings" or child.name == "Achievements":
			continue  # Skip internal nodes, self, and our singletons
		child.free()
	
	# Wait one frame to ensure cleanup is complete
	await get_tree().process_frame
	
	# Load and instance the new main scene
	var new_main_scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(new_main_scene)
	get_tree().current_scene = new_main_scene
	AudioManager.ui_hit.play()
	await get_tree().create_timer(0.5).timeout
	AudioManager.hypertype_voice.play()
	queue_free()


func _on_difficulty_select_item_selected(index: int):
	var selected_id = difficulty_select.get_item_id(index)
	GameSettings.enemy_speed = selected_id


func _on_restart_button_pressed() -> void:
	if not can_restart:  # Ignore input if animations aren't done
		return
	restart_game()
