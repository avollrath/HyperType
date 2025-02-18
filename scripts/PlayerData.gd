# PlayerData.gd
extends Node

signal auth_state_changed(is_logged_in: bool)
signal stats_updated

var is_logged_in: bool = false

# Stats handling with explicit types
var stats = {
	"games_played": 0,  # int
	"total_score": 0,   # int
	"high_score": 0     # int
}

var unlocked_achievements = {}

func _ready():
	# Initialize with logged out state
	is_logged_in = false
	auth_state_changed.emit(false)

func login(username: String, password: String) -> Array:
	var result = await Talo.player_auth.login(username, password)
	if result[0] == OK and not result[1]: # Login successful and no verification needed
		is_logged_in = true
		auth_state_changed.emit(true)
		await load_stats()
	return result

func logout():
	is_logged_in = false
	auth_state_changed.emit(false)

func save_stats():
	if not is_logged_in or not Talo.current_player:
		print("Cannot save stats: Player not logged in")
		return
		
	# Save stats as props
	for stat_name in stats:
		var value = str(stats[stat_name])
		print("[SAVE STATS] Saving %s: %s" % [stat_name, value])
		await Talo.current_player.set_prop("stat_" + stat_name, value)
	
	# Save achievements
	await Talo.current_player.set_prop("achievements", JSON.stringify(unlocked_achievements))
	stats_updated.emit()

func load_stats():
	if not is_logged_in or not Talo.current_player:
		print("Cannot load stats: Player not logged in")
		return

	for stat_name in stats.keys():
		var value = await Talo.current_player.get_prop("stat_" + stat_name, "0")
		print("[LOAD STATS] Loading %s, raw value: %s" % [stat_name, value])
		
		match stat_name:
			"high_score", "games_played", "total_score", "total_deaths", "enemies_defeated", "bosses_defeated", "total_words_typed", "total_perfect_words_typed","perfect_levels_count", "comebacks_count":
				stats[stat_name] = int(value)
			"overall_accuracy", "total_playtime":
				stats[stat_name] = float(value)
			"level_complete_no_mistakes":
				stats[stat_name] = value.to_lower() == "true"
			_:
				stats[stat_name] = float(value) if "." in value else int(value)
		
		print("[LOAD STATS] Converted %s to: %s (%s)" % [
			stat_name, stats[stat_name], typeof(stats[stat_name])
		])
			
		print("[LOAD STATS] Converted %s to: %s (%s)" % [stat_name, stats[stat_name], typeof(stats[stat_name])])
	
	# Load achievements
	var achievements_json = await Talo.current_player.get_prop("achievements", "{}")
	unlocked_achievements = JSON.parse_string(achievements_json)
	if unlocked_achievements == null:
		unlocked_achievements = {}
	
	stats_updated.emit()

# Helper function to update a stat safely
func update_stat(stat_name: String, value) -> void:
	if not stats.has(stat_name):
		print("[ERROR] Attempting to update non-existent stat: ", stat_name)
		return
		
	if stat_name == "high_score":
		var current_high = stats["high_score"]
		print("[UPDATE STAT] Checking high score - Current: %d, New: %d" % [current_high, value])
		if value > current_high:
			stats["high_score"] = value
			print("[UPDATE STAT] New high score set: ", value)
	else:
		stats[stat_name] = value
	
	save_stats()
