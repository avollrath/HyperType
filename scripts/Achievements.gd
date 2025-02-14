extends Node

signal achievement_unlocked(achievement_id)  # Signal to trigger popups

const SAVE_FILE = "user://achievements.json"

var achievements = {}
var stats = {
	"total_playtime": 0,
	"total_words_typed": 0,
	"overall_accuracy": 0.0,
	"bosses_defeated": 0,
	"highest_level": 0,
	"total_deaths": 0,
	"enemies_defeated": 0
}

# Define achievement conditions
var achievement_conditions = {
	"marathon_typist": { "stat": "total_playtime", "value": 3600 },
	"typing_legend": { "stat": "total_words_typed", "value": 50000 },
	"flawless_typist": { "stat": "overall_accuracy", "value": 99.0 },
	"big_game_hunter": { "stat": "bosses_defeated", "value": 25 },
	"never_give_up": { "stat": "total_deaths", "value": 10 },
	"speed_demon": { "stat": "highest_level", "value": 20 },
	"enemy_slayer": { "stat": "enemies_defeated", "value": 100 }  # 50 enemies killed
}

func _ready():
	load_achievements()

### ✅ CHECK FOR ACHIEVEMENTS
func check_for_achievements():
	for achievement_id in achievement_conditions.keys():
		var condition = achievement_conditions[achievement_id]
		if stats.get(condition.stat, 0) >= condition.value:
			unlock_achievement(achievement_id)

### ✅ UNLOCK AN ACHIEVEMENT
func unlock_achievement(id: String):
	if not achievements.has(id):  # Unlock only if not already unlocked
		achievements[id] = true
		save_achievements()
		emit_signal("achievement_unlocked", id)  # 🔥 Trigger popup event
		print("Achievement unlocked:", id)

func is_unlocked(id: String) -> bool:
	return achievements.get(id, false)

### ✅ UPDATE STATS & CHECK FOR UNLOCKS
func update_stat(stat_name: String, value):
	if stats.has(stat_name):
		if typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT:
			stats[stat_name] += value
		else:
			stats[stat_name] = value
		save_achievements()
		check_for_achievements()

### ✅ SAVE/LOAD DATA
func save_achievements():
	var save_data = {
		"achievements": achievements,
		"stats": stats
	}
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))
	file.close()

func load_achievements():
	if FileAccess.file_exists(SAVE_FILE):
		var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
		var json_string = file.get_as_text()
		var save_data = JSON.parse_string(json_string)

		if save_data:
			achievements = save_data.get("achievements", {})
			stats = save_data.get("stats", stats)
