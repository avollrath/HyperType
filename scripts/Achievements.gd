extends Node

signal achievement_unlocked(achievement_id)

const SAVE_FILE = "user://achievements.json"
const DEFAULT_BADGE = "res://assets/sprites/badges/crosshair.webp"

# ------------------------------------------------------------------
# Persistent Achievements (saved across runs)
# ------------------------------------------------------------------
# Persistent Achievements (saved across runs)
const ACHIEVEMENTS = {
	# ------------------- Accuracy & Perfection (Persistent) -------------------
	"nailed_it": {
		"title": "Nailed It!",
		"description": "Complete a level without a single mistake",
		"condition": "level_complete_no_mistakes",
		"required_value": true,
		"voice_file": "res://assets/sounds/achievements/nailed_it.mp3",
		"badge": "res://assets/sprites/badges/nailed_it.png"
	},
	"perfection_party": {
		"title": "Perfection Party",
		"description": "Finish 5 levels perfectly",
		"condition": "perfect_levels_count",
		"required_value": 5,
		"voice_file": "res://assets/sounds/achievements/perfection_party.mp3",
		"badge": "res://assets/sprites/badges/perfection_party.png"
	},
	"typo_never": {
		"title": "Typo? Never!",
		"description": "Maintain 99% accuracy for 5 levels",
		"condition": "overall_accuracy",
		"required_value": 99.0,
		"voice_file": "res://assets/sounds/achievements/typo_never.mp3",
		"badge": "res://assets/sprites/badges/typo_never.png"
	},
	"zero_error_zone": {
		"title": "Zero Error Zone",
		"description": "Type 500 perfect words",
		"condition": "total_perfect_words_typed",
		"required_value": 500,
		"voice_file": "res://assets/sounds/achievements/zero_error_zone.mp3",
		"badge": "res://assets/sprites/badges/zero_error_zone.png"
	},
	"error_404": {
		"title": "Error 404: No Typos Found",
		"description": "Type 1000 perfect words overall",
		"condition": "total_perfect_words_typed",
		"required_value": 1000,
		"voice_file": "res://assets/sounds/achievements/error_404.mp3",
		"badge": "res://assets/sprites/badges/error_404.png"
	},

	# ------------------- Typing Volume & Speed (Persistent) -------------------
	"rapid_fire_fingers": {
		"title": "Rapid-Fire Fingers",
		"description": "Type 1,000 words in total",
		"condition": "total_words_typed",
		"required_value": 1000,
		"voice_file": "res://assets/sounds/achievements/rapid_fire_fingers.mp3",
		"badge": "res://assets/sprites/badges/rapid_fire_fingers.png"
	},
	"wordsmith_extraordinaire": {
		"title": "Wordsmith Extraordinaire",
		"description": "Type 50,000 words in total",
		"condition": "total_words_typed",
		"required_value": 50000,
		"voice_file": "res://assets/sounds/achievements/wordsmith_extraordinaire.mp3",
		"badge": "res://assets/sprites/badges/wordsmith_extraordinaire.png"
	},
	"typing_titan": {
		"title": "Typing Titan",
		"description": "Type 100,000 words in total",
		"condition": "total_words_typed",
		"required_value": 100000,
		"voice_file": "res://assets/sounds/achievements/typing_titan.mp3",
		"badge": "res://assets/sprites/badges/typing_titan.png"
	},

	# ------------------- Endurance (Playtime) (Persistent) -------------------
	"keyboard_marathon": {
		"title": "Keyboard Marathon",
		"description": "Play for 1 hour",
		"condition": "total_playtime",
		"required_value": 3600,
		"voice_file": "res://assets/sounds/achievements/keyboard_marathon.mp3",
		"badge": "res://assets/sprites/badges/keyboard_marathon.png"
	},
	"typathon_veteran": {
		"title": "Typathon Veteran",
		"description": "Play for 5 hours total",
		"condition": "total_playtime",
		"required_value": 18000,
		"voice_file": "res://assets/sounds/achievements/typathon_veteran.mp3",
		"badge": "res://assets/sprites/badges/typathon_veteran.png"
	},
	"keyboard_immortal": {
		"title": "Keyboard Immortal",
		"description": "Play for 10 hours total",
		"condition": "total_playtime",
		"required_value": 36000,
		"voice_file": "res://assets/sounds/achievements/keyboard_immortal.mp3",
		"badge": "res://assets/sprites/badges/keyboard_immortal.png"
	},

	# ------------------- Boss Battles (Persistent) -------------------
	"boss_basher": {
		"title": "Boss Basher",
		"description": "Defeat 25 bosses",
		"condition": "bosses_defeated",
		"required_value": 25,
		"voice_file": "res://assets/sounds/achievements/boss_basher.mp3",
		"badge": "res://assets/sprites/badges/boss_basher.png"
	},
	"boss_demolisher": {
		"title": "Boss Demolisher",
		"description": "Defeat 50 bosses",
		"condition": "bosses_defeated",
		"required_value": 50,
		"voice_file": "res://assets/sounds/achievements/boss_demolisher.mp3",
		"badge": "res://assets/sprites/badges/boss_demolisher.png"
	},
	"boss_obliterator": {
		"title": "Boss Obliterator",
		"description": "Defeat 100 bosses",
		"condition": "bosses_defeated",
		"required_value": 100,
		"voice_file": "res://assets/sounds/achievements/boss_obliterator.mp3",
		"badge": "res://assets/sprites/badges/boss_obliterator.png"
	},

	# ------------------- Enemy Defeat (Persistent) -------------------
	"first_blood": {
		"title": "First Blood",
		"description": "Defeat 1 enemy",
		"condition": "enemies_defeated",
		"required_value": 1,
		"voice_file": "res://assets/sounds/achievements/first_blood.mp3",
		"badge": "res://assets/sprites/badges/first_blood.png"
	},
	"enemy_annihilator": {
		"title": "Enemy Annihilator",
		"description": "Defeat 100 enemies",
		"condition": "enemies_defeated",
		"required_value": 100,
		"voice_file": "res://assets/sounds/achievements/enemy_annihilator.mp3",
		"badge": "res://assets/sprites/badges/enemy_annihilator.png"
	},
	"word_warlord": {
		"title": "Word Warlord",
		"description": "Defeat 1,000 enemies",
		"condition": "enemies_defeated",
		"required_value": 1000,
		"voice_file": "res://assets/sounds/achievements/word_warlord.mp3",
		"badge": "res://assets/sprites/badges/word_warlord.png"
	},
	"enemy_massacre": {
		"title": "Enemy Massacre",
		"description": "Defeat 10,000 enemies",
		"condition": "enemies_defeated",
		"required_value": 10000,
		"voice_file": "res://assets/sounds/achievements/enemy_massacre.mp3",
		"badge": "res://assets/sprites/badges/enemy_massacre.png"
	},

	# ------------------- Death & Resilience (Persistent) -------------------
	"bounce_back": {
		"title": "Bounce Back",
		"description": "Die 10 times",
		"condition": "total_deaths",
		"required_value": 10,
		"voice_file": "res://assets/sounds/achievements/bounce_back.mp3",
		"badge": "res://assets/sprites/badges/bounce_back.png"
	},
	"never_surrender": {
		"title": "Never Surrender",
		"description": "Die 30 times but keep fighting",
		"condition": "total_deaths",
		"required_value": 30,
		"voice_file": "res://assets/sounds/achievements/never_surrender.mp3",
		"badge": "res://assets/sprites/badges/never_surrender.png"
	},
	"rise_of_the_phoenix": {
		"title": "Rise of the Phoenix",
		"description": "Die 100 times and rise again",
		"condition": "total_deaths",
		"required_value": 100,
		"voice_file": "res://assets/sounds/achievements/rise_of_the_phoenix.mp3",
		"badge": "res://assets/sprites/badges/rise_of_the_phoenix.png"
	},

	# ------------------- Level Progression (Persistent) -------------------
	"level_up_legend": {
		"title": "Level Up Legend",
		"description": "Reach level 10",
		"condition": "highest_level",
		"required_value": 10,
		"voice_file": "res://assets/sounds/achievements/level_up_legend.mp3",
		"badge": "res://assets/sprites/badges/level_up_legend.png"
	},
	"next_level_ninjatypist": {
		"title": "Next-Level Ninjatypist",
		"description": "Reach level 30",
		"condition": "highest_level",
		"required_value": 30,
		"voice_file": "res://assets/sounds/achievements/next_level_ninjatypist.mp3",
		"badge": "res://assets/sprites/badges/next_level_ninjatypist.png"
	},
	"grandmaster_of_keys": {
		"title": "Grandmaster of Keys",
		"description": "Reach level 50",
		"condition": "highest_level",
		"required_value": 50,
		"voice_file": "res://assets/sounds/achievements/grandmaster_of_keys.mp3",
		"badge": "res://assets/sprites/badges/grandmaster_of_keys.png"
	},

	# ------------------- Perfect Level Finishes (Persistent) -------------------
	"flawless_frenzy": {
		"title": "Flawless Frenzy",
		"description": "Finish 10 levels perfectly",
		"condition": "perfect_levels_count",
		"required_value": 10,
		"voice_file": "res://assets/sounds/achievements/flawless_frenzy.mp3",
		"badge": "res://assets/sprites/badges/flawless_frenzy.png"
	},
	"untouchable_typist": {
		"title": "Untouchable Typist",
		"description": "Finish 20 levels perfectly",
		"condition": "perfect_levels_count",
		"required_value": 20,
		"voice_file": "res://assets/sounds/achievements/untouchable_typist.mp3",
		"badge": "res://assets/sprites/badges/untouchable_typist.png"
	},
	"perfection_overload": {
		"title": "Perfection Overload",
		"description": "Finish 50 levels perfectly",
		"condition": "perfect_levels_count",
		"required_value": 50,
		"voice_file": "res://assets/sounds/achievements/perfection_overload.mp3",
		"badge": "res://assets/sprites/badges/perfection_overload.png"
	},

	# ------------------- Comebacks (Persistent) -------------------
	"miracle_comeback": {
		"title": "Miracle Comeback",
		"description": "Achieve 1 comeback",
		"condition": "comebacks_count",
		"required_value": 1,
		"voice_file": "res://assets/sounds/achievements/miracle_comeback.mp3",
		"badge": "res://assets/sprites/badges/miracle_comeback.png"
	},
	"the_comeback_kid": {
		"title": "The Comeback Kid",
		"description": "Achieve 5 comebacks",
		"condition": "comebacks_count",
		"required_value": 10,
		"voice_file": "res://assets/sounds/achievements/the_comeback_kid.mp3",
		"badge": "res://assets/sprites/badges/the_comeback_kid.png"
	},
	"rising_from_the_ashes": {
		"title": "Rising from the Ashes",
		"description": "Achieve 10 comebacks",
		"condition": "comebacks_count",
		"required_value": 20,
		"voice_file": "res://assets/sounds/achievements/rising_from_the_ashes.mp3",
		"badge": "res://assets/sprites/badges/rising_from_the_ashes.png"
	},

	# ------------------- Overall Accuracy (Persistent) -------------------
	"precision_prodigy": {
		"title": "Precision Prodigy",
		"description": "Maintain an overall accuracy of 95%",
		"condition": "overall_accuracy",
		"required_value": 95.0,
		"voice_file": "res://assets/sounds/achievements/precision_prodigy.mp3",
		"badge": "res://assets/sprites/badges/precision_prodigy.png"
	},
	"surgical_precision": {
		"title": "Surgical Precision",
		"description": "Achieve an overall accuracy of 99.5%",
		"condition": "overall_accuracy",
		"required_value": 99.5,
		"voice_file": "res://assets/sounds/achievements/surgical_precision.mp3",
		"badge": "res://assets/sprites/badges/surgical_precision.png"
	}
}

# Run-Based Achievements (per run; not saved)
const RUN_ACHIEVEMENTS = {
	# ------------------- Word Count in a Run -------------------
	"warmup_session": {
		"title": "Warm-Up Session",
		"description": "Type at least 50 words in a single run",
		"condition": "total_words_typed",
		"required_value": 50,
		"voice_file": "res://assets/sounds/achievements/warmup_session.mp3",
		"badge": "res://assets/sprites/badges/warmup_session.png"
	},
	"word_whirlwind": {
		"title": "Word Whirlwind",
		"description": "Type at least 200 words in a single run",
		"condition": "total_words_typed",
		"required_value": 200,
		"voice_file": "res://assets/sounds/achievements/word_whirlwind.mp3",
		"badge": "res://assets/sprites/badges/word_whirlwind.png"
	},
	"type_machine": {
		"title": "Type Machine",
		"description": "Type 500 words in one run",
		"condition": "total_words_typed",
		"required_value": 500,
		"voice_file": "res://assets/sounds/achievements/type_machine.mp3",
		"badge": "res://assets/sprites/badges/type_machine.png"
	},
	"run_of_champions": {
		"title": "Run of Champions",
		"description": "Type 1,000 words in one run",
		"condition": "total_words_typed",
		"required_value": 1000,
		"voice_file": "res://assets/sounds/achievements/run_of_champions.mp3",
		"badge": "res://assets/sprites/badges/run_of_champions.png"
	},

	# ------------------- Enemies Defeated in a Run -------------------
	"slaughter": {
		"title": "Slaughter",
		"description": "Defeat 10 enemies in one run",
		"condition": "enemies_defeated",
		"required_value": 20,
		"voice_file": "res://assets/sounds/achievements/slaughter.mp3",
		"badge": "res://assets/sprites/badges/slaughter.png"
	},
	"rampage": {
		"title": "Rampage",
		"description": "Defeat 50 enemies in one run",
		"condition": "enemies_defeated",
		"required_value": 50,
		"voice_file": "res://assets/sounds/achievements/rampage.mp3",
		"badge": "res://assets/sprites/badges/rampage.png"
	},
	"carnage_unleashed": {
		"title": "Carnage Unleashed",
		"description": "Defeat 200 enemies in one run",
		"condition": "enemies_defeated",
		"required_value": 200,
		"voice_file": "res://assets/sounds/achievements/carnage_unleashed.mp3",
		"badge": "res://assets/sprites/badges/carnage_unleashed.png"
	},

	# ------------------- Bosses Defeated in a Run -------------------
	"boss_buster": {
		"title": "Boss Buster",
		"description": "Defeat 1 boss in a single run",
		"condition": "bosses_defeated",
		"required_value": 1,
		"voice_file": "res://assets/sounds/achievements/boss_buster.mp3",
		"badge": "res://assets/sprites/badges/boss_buster.png"
	},
	"boss_basher": {
		"title": "Boss Basher",
		"description": "Defeat 3 bosses in one run",
		"condition": "bosses_defeated",
		"required_value": 3,
		"voice_file": "res://assets/sounds/achievements/boss_basher.mp3",
		"badge": "res://assets/sprites/badges/boss_basher.png"
	},
	"boss_annihilator": {
		"title": "Boss Annihilator",
		"description": "Defeat 5 bosses in one run",
		"condition": "bosses_defeated",
		"required_value": 10,
		"voice_file": "res://assets/sounds/achievements/boss_annihilator.mp3",
		"badge": "res://assets/sprites/badges/boss_annihilator.png"
	},
	"boss_crusher": {
		"title": "Boss Crusher",
		"description": "Defeat 2 bosses in one run",
		"condition": "bosses_defeated",
		"required_value": 5,
		"voice_file": "res://assets/sounds/achievements/run_boss_crusher.mp3",
		"badge": "res://assets/sprites/badges/run_boss_crusher.png"
	},

	# ------------------- Streaks in a Run -------------------
	"streak_spark": {
		"title": "Streak Spark",
		"description": "Achieve a 10-word streak in one run",
		"condition": "longest_streak",
		"required_value": 20,
		"voice_file": "res://assets/sounds/achievements/streak_spark.mp3",
		"badge": "res://assets/sprites/badges/streak_spark.png"
	},
	"streak_smasher": {
		"title": "Streak Smasher",
		"description": "Achieve a 25-word streak in one run",
		"condition": "longest_streak",
		"required_value": 50,
		"voice_file": "res://assets/sounds/achievements/streak_smasher.mp3",
		"badge": "res://assets/sprites/badges/streak_smasher.png"
	},
	"streak_master": {
		"title": "Streak Master",
		"description": "Achieve a 50-word streak in one run",
		"condition": "longest_streak",
		"required_value": 100,
		"voice_file": "res://assets/sounds/achievements/streak_master.mp3",
		"badge": "res://assets/sprites/badges/streak_master.png"
	},

	# ------------------- Run Accuracy & Survival -------------------
	"laser_focused_run": {
		"title": "Laser-Focused Run",
		"description": "Achieve at least 98% accuracy in one run",
		"condition": "overall_accuracy",
		"required_value": 98.0,
		"voice_file": "res://assets/sounds/achievements/laser_focused_run.mp3",
		"badge": "res://assets/sprites/badges/laser_focused_run.png"
	},
	"run_perfect_accuracy": {
		"title": "Flawless Run",
		"description": "Achieve 100% accuracy in one run",
		"condition": "overall_accuracy",
		"required_value": 100.0,
		"voice_file": "res://assets/sounds/achievements/run_perfect_accuracy.mp3",
		"badge": "res://assets/sprites/badges/run_perfect_accuracy.png"
	}
}



# ------------------------------------------------------------------
# Persistent Stats (saved in JSON)
# ------------------------------------------------------------------
var stats = {
	"total_playtime": 0,              # seconds of active gameplay
	"total_words_typed": 0,
	"total_perfect_words_typed": 0,
	"longest_streak": 0,
	"overall_accuracy": 0.0,
	"bosses_defeated": 0,
	"highest_level": 0,
	"total_deaths": 0,
	"enemies_defeated": 0,
	"level_complete_no_mistakes": false,
	"perfect_levels_count": 0,        # count of levels finished perfectly
	"comebacks_count": 0,
	"high_score": 0               # count of comebacks achieved
}

# ------------------------------------------------------------------
# Run-Specific Stats (not saved; reset each run)
# ------------------------------------------------------------------
var run_stats = {
	"total_words_typed": 0,
	"enemies_defeated": 0,
	"bosses_defeated": 0,
	"longest_streak": 0,
	"overall_accuracy": 0.0,
	"total_deaths": 0
}

# ------------------------------------------------------------------
# Unlocked Achievements (persistent, saved)
# ------------------------------------------------------------------
var unlocked_achievements = {}

# ============================================================================
# _ready() – Load persistent data on startup
# ============================================================================
func _ready():
	load_achievements()

# ============================================================================
# UPDATE FUNCTION (updates both persistent and run stats if key exists)
# ============================================================================
func update_stat(stat_name: String, value):
	if stats.has(stat_name):
		if typeof(value) == TYPE_BOOL:
			stats[stat_name] = value
		elif typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT:
			stats[stat_name] += value
		else:
			stats[stat_name] = value
	if run_stats.has(stat_name):
		if typeof(value) == TYPE_BOOL:
			run_stats[stat_name] = value
		elif typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT:
			run_stats[stat_name] += value
		else:
			run_stats[stat_name] = value
	save_achievements()
	check_for_achievements()
	check_run_achievements()

# ============================================================================
# SET FUNCTION (overwrites stat value rather than adding)
# ============================================================================
func set_stat(stat_name: String, value):
	if stats.has(stat_name):
		stats[stat_name] = value
	if run_stats.has(stat_name):
		run_stats[stat_name] = value
	save_achievements()
	check_for_achievements()
	check_run_achievements()

# ============================================================================
# PERSISTENT ACHIEVEMENT CHECK
# ============================================================================
func check_for_achievements():
	for achievement_id in ACHIEVEMENTS.keys():
		if not is_unlocked(achievement_id):
			var achievement = ACHIEVEMENTS[achievement_id]
			var condition = achievement.condition
			var required_value = achievement.required_value
			var current_value = stats.get(condition)
			if typeof(required_value) == TYPE_BOOL:
				if typeof(current_value) == TYPE_BOOL and current_value == required_value:
					unlock_achievement(achievement_id)
			else:
				if typeof(current_value) != TYPE_BOOL and current_value >= required_value:
					unlock_achievement(achievement_id)

# ============================================================================
# RUN-BASED ACHIEVEMENT CHECK
# ============================================================================
func check_run_achievements():
	for achievement_id in RUN_ACHIEVEMENTS.keys():
		if not is_unlocked(achievement_id):
			var achievement = RUN_ACHIEVEMENTS[achievement_id]
			var condition = achievement.condition
			var required_value = achievement.required_value
			var current_value = run_stats.get(condition)
			if typeof(required_value) == TYPE_BOOL:
				if typeof(current_value) == TYPE_BOOL and current_value == required_value:
					unlock_achievement(achievement_id)
			else:
				if typeof(current_value) != TYPE_BOOL and current_value >= required_value:
					unlock_achievement(achievement_id)

# ============================================================================
# RESET RUN STATS (call at the start of each run)
# ============================================================================
func reset_run_stats():
	run_stats["total_words_typed"] = 0
	run_stats["enemies_defeated"] = 0
	run_stats["bosses_defeated"] = 0
	run_stats["longest_streak"] = 0
	run_stats["overall_accuracy"] = 0.0
	run_stats["total_deaths"] = 0


# ============================================================================
# UNLOCKING & QUERY FUNCTIONS
# ============================================================================
func unlock_achievement(id: String):
	if not unlocked_achievements.has(id):
		unlocked_achievements[id] = true
		save_achievements()
		emit_signal("achievement_unlocked", id)
		var title = ACHIEVEMENTS[id].title if ACHIEVEMENTS.has(id) else RUN_ACHIEVEMENTS[id].title
		print("Achievement unlocked:", title)

func is_unlocked(id: String) -> bool:
	return unlocked_achievements.get(id, false)

# ============================================================================
# GET BADGE TEXTURE (returns a Texture2D for the given achievement)
# ============================================================================
func get_badge_texture(achievement_id: String) -> Texture2D:
	if ACHIEVEMENTS.has(achievement_id):
		var achievement = ACHIEVEMENTS[achievement_id]
		if achievement.has("badge"):
			var badge = load(achievement.badge) as Texture2D
			if badge:
				return badge
	elif RUN_ACHIEVEMENTS.has(achievement_id):
		var achievement = RUN_ACHIEVEMENTS[achievement_id]
		if achievement.has("badge"):
			var badge = load(achievement.badge) as Texture2D
			if badge:
				return badge
	return load(DEFAULT_BADGE) as Texture2D

# ============================================================================
# SAVE / LOAD FUNCTIONS (Persistent stats only)
# ============================================================================
func save_achievements():
	var save_data = {
		"achievements": unlocked_achievements,
		"stats": stats
	}
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))
	file.close()

func load_achievements():
	if FileAccess.file_exists(SAVE_FILE):
		var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
		var json_string = file.get_as_text()
		file.close()

		# Debugging: Print what was read from file
		print("Loaded JSON:", json_string)

		# Parse JSON safely
		var result = JSON.parse_string(json_string)

		# Check if parsing failed
		if result == null:
			print("Error parsing achievements JSON: Data is null. File might be corrupted.")
			return

		# Load saved data
		unlocked_achievements = result.get("achievements", {})
		stats = result.get("stats", stats)
