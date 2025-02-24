extends CanvasLayer

enum GameState { MAIN_MENU, LOGIN, REGISTER, DIFFICULTY }

# UI Containers
@onready var main_container: VBoxContainer = $ColorRect/MainContainer
@onready var auth_container: VBoxContainer = $ColorRect/AuthContainer
@onready var difficulty_container: VBoxContainer = $ColorRect/DifficultyContainer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Main Menu Buttons
@onready var login_menu_button: Button = $ColorRect/MainContainer/LoginButton
@onready var register_menu_button: Button = $ColorRect/MainContainer/RegisterButton
@onready var guest_menu_button: Button = $ColorRect/MainContainer/GuestButton

# Auth UI Components
@onready var username_input: LineEdit = $ColorRect/AuthContainer/Username
@onready var password_input: LineEdit = $ColorRect/AuthContainer/Password
@onready var email_input: LineEdit = $ColorRect/AuthContainer/Email
@onready var submit_button: Button = $ColorRect/AuthContainer/SubmitButton
@onready var back_button: Button = $ColorRect/AuthContainer/BackButton
@onready var message_label: Label = $ColorRect/AuthContainer/Message

# User Info Display
@onready var user_info_container: HBoxContainer = $ColorRect/DifficultyContainer/UserInfo
@onready var username_label: Label = $ColorRect/DifficultyContainer/UserInfo/Username
@onready var logout_button: Button = $ColorRect/DifficultyContainer/LogoutButton

# Game Entities
@onready var enemy: CharacterBody2D = $Node2D/Enemy
@onready var player: CharacterBody2D = $Node2D/Player
@onready var ship_enemy: CharacterBody2D = $Node2D/ShipEnemy
@onready var robot_enemy: CharacterBody2D = $Node2D/RobotEnemy
@onready var small_enemy: CharacterBody2D = $Node2D/SmallEnemy
@onready var tank_enemy: CharacterBody2D = $Node2D/TankEnemy

# Difficulty Buttons
@onready var difficulty_buttons = {
	"beginner": {"node": $ColorRect/DifficultyContainer/Beginner, "speed": 40},
	"casual": {"node": $ColorRect/DifficultyContainer/Casual, "speed": 100},
	"challenging": {"node": $ColorRect/DifficultyContainer/Challenging, "speed": 190},
	"expert": {"node": $ColorRect/DifficultyContainer/Expert, "speed": 240},
	"pro": {"node": $ColorRect/DifficultyContainer/Pro, "speed": 310},
	"insane": {"node": $ColorRect/DifficultyContainer/Insane, "speed": 400}
}

var current_state: GameState = GameState.MAIN_MENU

func _ready():
	PlayerData.auth_state_changed.connect(_on_auth_state_changed)
	_setup_connections()
	_initialize_game_entities()
	await check_existing_auth()  # Wait for auth check to complete

func _setup_connections():
	# Main menu buttons
	login_menu_button.pressed.connect(func(): _change_state(GameState.LOGIN))
	register_menu_button.pressed.connect(func(): _change_state(GameState.REGISTER))
	guest_menu_button.pressed.connect(_on_guest_mode_pressed)
	
	# Auth buttons
	submit_button.pressed.connect(_on_submit_pressed)
	back_button.pressed.connect(func(): _change_state(GameState.MAIN_MENU))
	logout_button.pressed.connect(_on_logout_pressed)
	
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
	
	match current_state:
		GameState.MAIN_MENU:
			main_container.show()
			main_container.get_child(0).grab_focus()
		GameState.LOGIN, GameState.REGISTER:
			auth_container.show()
			submit_button.text = "Login" if current_state == GameState.LOGIN else "Create Account"
			email_input.visible = (current_state == GameState.REGISTER)
			username_input.grab_focus()
		GameState.DIFFICULTY:
			difficulty_container.show()
			_update_user_info()
			difficulty_buttons.challenging.node.grab_focus()

func _update_user_info():
	if PlayerData.is_logged_in and Talo.current_player:
		print('Player props', Talo.current_alias)
		username_label.text = "Playing as: " + str(Talo.current_alias.identifier)
		logout_button.show()
	else:
		username_label.text = "Playing as Guest"
		logout_button.hide()

func _on_guest_mode_pressed():
	PlayerData.is_logged_in = false
	_change_state(GameState.DIFFICULTY)

func _on_logout_pressed():
	PlayerData.is_logged_in = false
	_change_state(GameState.MAIN_MENU)

func _on_auth_state_changed(is_logged_in: bool):
	if is_logged_in:
		_change_state(GameState.DIFFICULTY)
		if PlayerData.is_logged_in:
			load_achievements()
			await PlayerData.load_stats()
	else:
		_change_state(GameState.MAIN_MENU)

func _on_submit_pressed():
	if current_state == GameState.LOGIN:
		_on_login_pressed()
	else:
		_on_register_pressed()

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

func start_game(speed: int):
	AudioManager.click.play()
	GameSettings.enemy_speed = speed
	animation_player.play("intro")
	
	var main_scene = load("res://scenes/main.tscn").instantiate()
	get_parent().add_child(main_scene)
	await animation_player.animation_finished
	AudioManager.background_music.play()
	queue_free()

func load_achievements():
	var achievements_json = await Talo.current_player.get_prop("achievements", "{}")
	var parsed = JSON.parse_string(achievements_json)
	Achievements.unlocked_achievements = parsed
