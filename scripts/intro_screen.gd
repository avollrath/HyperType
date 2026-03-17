extends CanvasLayer

enum GameState { MAIN_MENU, LOGIN, REGISTER, DIFFICULTY, ACHIEVEMENTS }

# UI Containers
@onready var main_container: VBoxContainer = $ColorRect/MainContainer
@onready var auth_container: VBoxContainer = $ColorRect/AuthContainer
@onready var difficulty_container: VBoxContainer = $ColorRect/DifficultyContainer
@onready var achievements_container: VBoxContainer = $ColorRect/AchievementsContainer
@onready var achievements_grid: GridContainer = $ColorRect/AchievementsContainer/ScrollContainer/AchievementsGrid
@onready var achievements_summary: Label = $ColorRect/AchievementsContainer/Summary
@onready var background_panel: Panel = $ColorRect/Panel
@onready var title_label: Label = $ColorRect/Title
@onready var achievements_divider: ColorRect = $ColorRect/DifficultyContainer/Divider
@onready var guest_back_action: BaseButton = $ColorRect/DifficultyContainer/GuestBackButton
@onready var quit_divider: ColorRect = $ColorRect/DifficultyContainer/BottomDivider
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Main Menu Buttons
@onready var login_menu_button: Button = $ColorRect/MainContainer/LoginButton
@onready var guest_menu_button: Button = $ColorRect/MainContainer/GuestButton
@onready var main_menu_quit_button: Button = $ColorRect/MainContainer/QuitButton

# Auth UI Components
@onready var username_input: LineEdit = $ColorRect/AuthContainer/Username
@onready var password_input: LineEdit = $ColorRect/AuthContainer/Password
@onready var email_input: LineEdit = $ColorRect/AuthContainer/Email
@onready var submit_button: Button = $ColorRect/AuthContainer/SubmitButton
@onready var back_button: Button = $ColorRect/AuthContainer/BackButton
@onready var auth_toggle_button: BaseButton = $ColorRect/AuthContainer/AuthToggleButton
@onready var message_label: Label = $ColorRect/AuthContainer/Message

# User Info Display
@onready var user_info_container: HBoxContainer = $ColorRect/DifficultyContainer/UserInfo
@onready var username_label: Label = $ColorRect/DifficultyContainer/UserInfo/Username
@onready var show_achievements_button: Button = $ColorRect/DifficultyContainer/ShowAchievementsButton
@onready var logout_button: BaseButton = $ColorRect/DifficultyContainer/UserInfo/LogoutButton
@onready var quit_button: Button = $ColorRect/DifficultyContainer/QuitButton
@onready var achievements_back_button: Button = $ColorRect/AchievementsContainer/BackButton

# Game Entities
@onready var enemy: CharacterBody2D = $Node2D/Enemy
@onready var player: CharacterBody2D = $Node2D/Player
@onready var ship_enemy: CharacterBody2D = $Node2D/ShipEnemy
@onready var robot_enemy: CharacterBody2D = $Node2D/RobotEnemy
@onready var small_enemy: CharacterBody2D = $Node2D/SmallEnemy
@onready var tank_enemy: CharacterBody2D = $Node2D/TankEnemy
@onready var casual_button: Button = $ColorRect/DifficultyContainer/Casual
@onready var expert_button: Button = $ColorRect/DifficultyContainer/Expert
@onready var pro_button: Button = $ColorRect/DifficultyContainer/Pro

# Difficulty Buttons
@onready var difficulty_buttons = {
	"beginner": {"node": $ColorRect/DifficultyContainer/Beginner, "speed": 40},
	"challenging": {"node": $ColorRect/DifficultyContainer/Challenging, "speed": 190},
	"insane": {"node": $ColorRect/DifficultyContainer/Insane, "speed": 400}
}

var current_state: GameState = GameState.MAIN_MENU
var is_starting_game := false
var achievement_card_stylebox: StyleBoxFlat

const DEFAULT_PANEL_SIZE := Vector2(760, 757)
const ACHIEVEMENTS_PANEL_SIZE := Vector2(1160, 757)

func _ready():
	PlayerData.auth_state_changed.connect(_on_auth_state_changed)
	_create_achievement_card_stylebox()
	_setup_connections()
	_hide_unused_difficulty_buttons()
	_initialize_game_entities()
	await check_existing_auth()  # Wait for auth check to complete

func _setup_connections():
	# Main menu buttons
	login_menu_button.pressed.connect(func(): _change_state(GameState.LOGIN))
	guest_menu_button.pressed.connect(_on_guest_mode_pressed)
	main_menu_quit_button.pressed.connect(_on_quit_pressed)
	
	# Auth buttons
	submit_button.pressed.connect(_on_submit_pressed)
	back_button.pressed.connect(func(): _change_state(GameState.MAIN_MENU))
	auth_toggle_button.pressed.connect(_on_auth_toggle_pressed)
	logout_button.pressed.connect(_on_logout_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	show_achievements_button.pressed.connect(_on_show_achievements_pressed)
	guest_back_action.pressed.connect(func(): _change_state(GameState.MAIN_MENU))
	achievements_back_button.pressed.connect(func(): _change_state(GameState.DIFFICULTY))
	
	# Difficulty buttons
	for difficulty in difficulty_buttons:
		var button_data = difficulty_buttons[difficulty]
		button_data.node.pressed.connect(
			func(): start_game(button_data.speed)
		)

func _initialize_game_entities():
	# Warm up particle systems
	enemy.die()
	ship_enemy.die()
	robot_enemy.die()
	small_enemy.die()
	tank_enemy.die()
	player.take_damage()

func check_existing_auth() -> void:
	# Wait for the player to be available
	while not Talo.current_player:
		await get_tree().process_frame
	
	# If we have a current player, we're logged in
	if Talo.current_player:
		PlayerData.is_logged_in = true
		_change_state(GameState.DIFFICULTY)  # Go directly to difficulty screen
		PlayerData.auth_state_changed.emit(true)

func _change_state(new_state: GameState):
	current_state = new_state
	_update_ui()

func _update_ui():
	# Hide all containers first
	main_container.hide()
	auth_container.hide()
	difficulty_container.hide()
	achievements_container.hide()
	title_label.show()
	_set_panel_size(DEFAULT_PANEL_SIZE)
	
	match current_state:
		GameState.MAIN_MENU:
			main_container.show()
			main_container.get_child(0).grab_focus()
		GameState.LOGIN, GameState.REGISTER:
			auth_container.show()
			submit_button.text = "Login" if current_state == GameState.LOGIN else "Create Account"
			email_input.visible = (current_state == GameState.REGISTER)
			auth_toggle_button.text = "(Create account)" if current_state == GameState.LOGIN else "(Back to login)"
			username_input.grab_focus()
		GameState.DIFFICULTY:
			difficulty_container.show()
			_update_user_info()
			difficulty_buttons.challenging.node.grab_focus()
		GameState.ACHIEVEMENTS:
			title_label.hide()
			_set_panel_size(ACHIEVEMENTS_PANEL_SIZE)
			achievements_container.show()
			_refresh_achievements_view()
			achievements_back_button.grab_focus()

func _set_panel_size(panel_size: Vector2) -> void:
	background_panel.offset_left = -panel_size.x / 2.0
	background_panel.offset_right = panel_size.x / 2.0
	background_panel.offset_top = -407.0
	background_panel.offset_bottom = 350.0

func _update_user_info():
	if PlayerData.is_logged_in and Talo.current_player:
		print('Player props', Talo.current_alias)
		username_label.text = "Playing as: " + str(Talo.current_alias.identifier)
		logout_button.show()
		show_achievements_button.show()
		achievements_divider.show()
		guest_back_action.hide()
		quit_divider.show()
	else:
		username_label.text = "Playing as Guest"
		logout_button.hide()
		show_achievements_button.hide()
		achievements_divider.show()
		guest_back_action.show()
		quit_divider.show()

func _on_guest_mode_pressed():
	PlayerData.is_logged_in = false
	Achievements.reset_guest_progress()
	_change_state(GameState.DIFFICULTY)

func _on_logout_pressed():
	await PlayerData.logout()
	Achievements.reset_guest_progress()
	_change_state(GameState.MAIN_MENU)

func _on_quit_pressed():
	get_tree().quit()

func _on_show_achievements_pressed():
	if not PlayerData.is_logged_in:
		return
	_change_state(GameState.ACHIEVEMENTS)

func _on_auth_state_changed(is_logged_in: bool):
	if is_logged_in:
		_change_state(GameState.DIFFICULTY)
		if PlayerData.is_logged_in:
			load_achievements()
			await PlayerData.load_stats()
	else:
		Achievements.reset_guest_progress()
		_change_state(GameState.MAIN_MENU)

func _on_submit_pressed():
	if current_state == GameState.LOGIN:
		_on_login_pressed()
	else:
		_on_register_pressed()

func _on_auth_toggle_pressed() -> void:
	if current_state == GameState.LOGIN:
		_change_state(GameState.REGISTER)
	else:
		_change_state(GameState.LOGIN)

func _on_login_pressed():
	if not _validate_auth_inputs():
		return
		
	var result = await PlayerData.login(username_input.text, password_input.text)
	if result[0] != OK:
		_handle_auth_error(Talo.player_auth.last_error.get_code())
	else:
		_on_auth_success()

func _on_register_pressed():
	if not _validate_auth_inputs():
		return
		
	var result = await Talo.player_auth.register(
		username_input.text,
		password_input.text,
		email_input.text,
		false
	)
	
	if result != OK:
		_handle_auth_error(Talo.player_auth.last_error.get_code())
	else:
		_on_auth_success()

func _validate_auth_inputs() -> bool:
	if username_input.text.is_empty() or password_input.text.is_empty():
		message_label.text = "Please fill in all required fields"
		return false
	return true

func _handle_auth_error(error_code: int):
	match error_code:
		TaloAuthError.ErrorCode.INVALID_CREDENTIALS:
			message_label.text = "Invalid username or password"
		TaloAuthError.ErrorCode.IDENTIFIER_TAKEN:
			message_label.text = "Username already taken"
		_:
			message_label.text = Talo.player_auth.last_error.get_string()

func _on_auth_success():
	message_label.text = "Login successful!"
	_change_state(GameState.DIFFICULTY)

func playHit() -> void:
	if is_instance_valid(AudioManager) and AudioManager.ui_hit:
		AudioManager.ui_hit.play()

func playVoice() -> void:
	if is_instance_valid(AudioManager) and AudioManager.hypertype_voice:
		AudioManager.hypertype_voice.play()

func start_game(speed: int):
	if is_starting_game:
		return

	is_starting_game = true
	if not PlayerData.is_logged_in:
		Achievements.reset_guest_progress()
	AudioManager.click.play()
	GameSettings.enemy_speed = speed
	_set_difficulty_buttons_enabled(false)
	username_label.text = "Preparing shaders and particles..."
	animation_player.play("intro")
	
	var main_scene = load("res://scenes/main.tscn").instantiate()
	get_parent().add_child(main_scene)
	get_tree().current_scene = main_scene
	if main_scene.has_method("warm_up_gpu"):
		await main_scene.warm_up_gpu()
	if animation_player.is_playing():
		await animation_player.animation_finished
	AudioManager.background_music.play()
	queue_free()

func _set_difficulty_buttons_enabled(enabled: bool) -> void:
	for difficulty in difficulty_buttons:
		var button_data = difficulty_buttons[difficulty]
		button_data.node.disabled = not enabled

func _hide_unused_difficulty_buttons() -> void:
	casual_button.hide()
	expert_button.hide()
	pro_button.hide()

func load_achievements():
	var achievements_json = await Talo.current_player.get_prop("achievements", "{}")
	var parsed = JSON.parse_string(achievements_json)
	Achievements.unlocked_achievements = parsed if parsed != null else {}
	if achievements_grid:
		_refresh_achievements_view()

func _create_achievement_card_stylebox() -> void:
	achievement_card_stylebox = StyleBoxFlat.new()
	achievement_card_stylebox.bg_color = Color(0.11, 0.02, 0.13, 0.92)
	achievement_card_stylebox.border_width_left = 2
	achievement_card_stylebox.border_width_top = 2
	achievement_card_stylebox.border_width_right = 2
	achievement_card_stylebox.border_width_bottom = 2
	achievement_card_stylebox.border_color = Color(1.0, 0.0, 0.65, 1.0)
	achievement_card_stylebox.corner_radius_top_left = 12
	achievement_card_stylebox.corner_radius_top_right = 12
	achievement_card_stylebox.corner_radius_bottom_right = 12
	achievement_card_stylebox.corner_radius_bottom_left = 12
	achievement_card_stylebox.content_margin_left = 16
	achievement_card_stylebox.content_margin_top = 16
	achievement_card_stylebox.content_margin_right = 16
	achievement_card_stylebox.content_margin_bottom = 16

func _refresh_achievements_view() -> void:
	if not achievements_grid:
		return

	for child in achievements_grid.get_children():
		child.queue_free()

	var unlocked_ids: Array[String] = []
	var locked_ids: Array[String] = []
	var unlocked_count := 0
	for achievement_id in Achievements.ACHIEVEMENTS.keys():
		if Achievements.is_unlocked(achievement_id):
			unlocked_count += 1
			unlocked_ids.append(achievement_id)
		else:
			locked_ids.append(achievement_id)

	for achievement_id in unlocked_ids:
		achievements_grid.add_child(_build_achievement_card(achievement_id, Achievements.ACHIEVEMENTS[achievement_id]))

	for achievement_id in locked_ids:
		achievements_grid.add_child(_build_achievement_card(achievement_id, Achievements.ACHIEVEMENTS[achievement_id]))

	achievements_summary.text = "Unlocked %d / %d" % [unlocked_count, Achievements.ACHIEVEMENTS.size()]

func _build_achievement_card(achievement_id: String, achievement_data: Dictionary) -> PanelContainer:
	var is_unlocked := Achievements.is_unlocked(achievement_id)
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(250, 240)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", achievement_card_stylebox)
	card.modulate = Color.WHITE if is_unlocked else Color(0.48, 0.48, 0.55, 0.95)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	card.add_child(content)

	var badge := TextureRect.new()
	badge.custom_minimum_size = Vector2(96, 96)
	badge.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	badge.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	badge.texture = Achievements.get_badge_texture(achievement_id)
	badge.self_modulate = Color.WHITE if is_unlocked else Color(0.7, 0.7, 0.75, 0.9)
	content.add_child(badge)

	var title := Label.new()
	title.text = str(achievement_data.get("title", achievement_id))
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.theme = background_panel.theme
	title.add_theme_font_size_override("font_size", 20)
	content.add_child(title)

	var status := Label.new()
	status.text = "Unlocked" if is_unlocked else "Locked"
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status.theme = background_panel.theme
	status.add_theme_color_override("font_color", Color(0.45, 1.0, 0.7, 1.0) if is_unlocked else Color(1.0, 0.55, 0.75, 1.0))
	content.add_child(status)

	var condition := Label.new()
	condition.text = "Condition: %s" % str(achievement_data.get("description", ""))
	condition.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	condition.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	condition.theme = background_panel.theme
	condition.add_theme_font_size_override("font_size", 16)
	content.add_child(condition)

	return card
