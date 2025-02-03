# GameOverScreen.gd
extends Control

@onready var high_score_label: Label = $VBoxContainer/HighScoreLabel
@onready var time_played_label: Label = $VBoxContainer/TimePlayedLabel
@onready var correct_words_label: Label = $VBoxContainer/CorrectWordsLabel
@onready var accuracy_label: Label = $VBoxContainer/AccuracyLabel
@onready var longest_streak_label: Label = $VBoxContainer/LongestStreakLabel
@onready var wpm_label: Label = $VBoxContainer/WPMLabel
@onready var level_label: Label = $VBoxContainer/LevelLabel

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
		longest_streak_label.text = "%d" % _display_longest_streak

var _display_wpm: float = 0.0
var display_wpm: float:
	get:
		return _display_wpm
	set(value):
		_display_wpm = value
		wpm_label.text = "%.1f" % _display_wpm

# --- End of animated properties ---

func _ready():
	if not high_score_label:
		print("HighScoreLabel not found!")
	if not level_label:
		print("LevelLabel not found!")

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

	# Animate each value sequentially.
	# High Score
	var tween = create_tween()
	tween.tween_property(self, "display_score", stats.score, 2.0).set_trans(Tween.TRANS_LINEAR)
	await tween.finished

	# Level
	tween = create_tween()
	tween.tween_property(self, "display_level", stats.level, 1.0).set_trans(Tween.TRANS_LINEAR)
	await tween.finished

	# Time Played
	tween = create_tween()
	tween.tween_property(self, "display_time", stats.time_played, 0.5).set_trans(Tween.TRANS_LINEAR)
	await tween.finished

	# Correct Words
	tween = create_tween()
	tween.tween_property(self, "display_correct_words", stats.correct_words, 0.5).set_trans(Tween.TRANS_LINEAR)
	await tween.finished

	# Accuracy (the animated value here is just the percent)
	tween = create_tween()
	tween.tween_property(self, "display_accuracy", stats.accuracy, 0.5).set_trans(Tween.TRANS_LINEAR)
	await tween.finished

	# Longest Streak
	tween = create_tween()
	tween.tween_property(self, "display_longest_streak", stats.longest_streak, 0.5).set_trans(Tween.TRANS_LINEAR)
	await tween.finished

	# WPM
	tween = create_tween()
	tween.tween_property(self, "display_wpm", stats.wpm, 0.5).set_trans(Tween.TRANS_LINEAR)
	await tween.finished

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		var root = get_tree().root
		
		# Remove the Game Over scene
		queue_free()
		
		# Remove the current Main scene if it exists
		var main_scene = root.get_node_or_null("Main")
		if main_scene:
			main_scene.queue_free()
		
		# Load a fresh instance of the Main scene
		var new_main_scene = load("res://scenes/main.tscn").instantiate()
		root.add_child(new_main_scene)  # Add it to the root

		# Set the new scene as the current one
		get_tree().current_scene = new_main_scene
