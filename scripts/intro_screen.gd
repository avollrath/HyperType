extends CanvasLayer

# Original difficulty selection nodes
@onready var difficulty_container: VBoxContainer = $ColorRect/VBoxContainer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var beginner: FancyButton = $ColorRect/VBoxContainer/Beginner
@onready var casual: FancyButton = $ColorRect/VBoxContainer/Casual
@onready var challenging: FancyButton = $ColorRect/VBoxContainer/Challenging
@onready var expert: FancyButton = $ColorRect/VBoxContainer/Expert
@onready var pro: FancyButton = $ColorRect/VBoxContainer/Pro
@onready var insane: FancyButton = $ColorRect/VBoxContainer/Insane

# Auth UI nodes
@onready var auth_container: VBoxContainer = $ColorRect/AuthContainer
@onready var username_input: LineEdit = $ColorRect/AuthContainer/Username
@onready var password_input: LineEdit = $ColorRect/AuthContainer/Password
@onready var email_input: LineEdit = $ColorRect/AuthContainer/Email
@onready var login_button: Button = $ColorRect/AuthContainer/LoginButton
@onready var register_button: Button = $ColorRect/AuthContainer/RegisterButton
@onready var message_label: Label = $ColorRect/AuthContainer/Message
@onready var disable_verification_button: Button = $ColorRect/AuthContainer/DisableVerificationButton
@onready var guest_button: Button = $ColorRect/AuthContainer/GuestButton

@onready var enemy: CharacterBody2D = $Node2D/Enemy
@onready var player: CharacterBody2D = $Node2D/Player
@onready var ship_enemy: CharacterBody2D = $Node2D/ShipEnemy
@onready var robot_enemy: CharacterBody2D = $Node2D/RobotEnemy
@onready var small_enemy: CharacterBody2D = $Node2D/SmallEnemy
@onready var tank_enemy: CharacterBody2D = $Node2D/TankEnemy

func _ready():
	PlayerData.auth_state_changed.connect(_on_auth_state_changed)
	
	check_existing_auth()
	
	# Connect auth buttons
	login_button.pressed.connect(_on_login_pressed)
	register_button.pressed.connect(_on_register_pressed)
	disable_verification_button.pressed.connect(disable_verification)
	guest_button.pressed.connect(_on_guest_mode_pressed)
	# Connect difficulty buttons
	beginner.pressed.connect(func(): start_game(40))
	casual.pressed.connect(func(): start_game(100))
	challenging.pressed.connect(func(): start_game(190))
	expert.pressed.connect(func(): start_game(240))
	pro.pressed.connect(func(): start_game(310))
	insane.pressed.connect(func(): start_game(400))
	
	enemy.die()
	ship_enemy.die()
	robot_enemy.die()
	small_enemy.die()
	tank_enemy.die()
	player.take_damage()
	# Check initial auth state
	_on_auth_state_changed(PlayerData.is_logged_in)
	
	# Focus username field initially if not logged in
	if not PlayerData.is_logged_in:
		username_input.grab_focus()
		
func check_existing_auth() -> void:
	# You might wait a few frames until the async identification completes.
	while not Talo.current_player:
		await get_tree().process_frame  # Wait for the next frame.
	# Now we have a player, update our state:
	PlayerData.is_logged_in = true
	PlayerData.auth_state_changed.emit(true)
	
func _on_guest_mode_pressed():
	# Hide authentication UI and show difficulty selection screen
	auth_container.hide()
	difficulty_container.show()
	challenging.grab_focus()

	# Ensure guest mode doesn't load/save achievements or stats
	PlayerData.is_logged_in = false

func _on_auth_state_changed(is_logged_in: bool):
	if is_logged_in:
		auth_container.hide()
		difficulty_container.show()
		challenging.grab_focus()
		if PlayerData.is_logged_in:  # Only load stats if NOT guest mode
			load_achievements()
			await PlayerData.load_stats()
	else:
		auth_container.show()
		difficulty_container.hide()
		username_input.grab_focus()
		
func load_achievements():
	var achievements_json = await Talo.current_player.get_prop("achievements", "{}")
	var parsed = JSON.parse_string(achievements_json)
	Achievements.unlocked_achievements = parsed

func _on_login_pressed():
	if username_input.text.is_empty() or password_input.text.is_empty():
		message_label.text = "Please fill in all fields"
		return
		
	var result = await PlayerData.login(username_input.text, password_input.text)
	if result[0] != OK:
		match Talo.player_auth.last_error.get_code():
			TaloAuthError.ErrorCode.INVALID_CREDENTIALS:
				message_label.text = "Invalid username or password"
			_:
				message_label.text = Talo.player_auth.last_error.get_string()
	else:
		if result[1]: # Needs verification
			message_label.text = "Please check your email for verification code"
			# You might want to show a verification code input here
		else:
			_on_auth_success()
			
func disable_verification():
	var result = await Talo.player_auth.toggle_verification(
		password_input.text, # Current password
		false # Disable verification
	)
	if result == OK:
		message_label.text = "Verification disabled, try logging in again"

func _on_register_pressed():
	if username_input.text.is_empty() or password_input.text.is_empty():
		message_label.text = "Please fill in all fields"
		return
		
	var result = await Talo.player_auth.register(
		username_input.text, 
		password_input.text,
		"", # Empty email
		false # Explicitly disable verification
	)
	
	if result != OK:
		match Talo.player_auth.last_error.get_code():
			TaloAuthError.ErrorCode.IDENTIFIER_TAKEN:
				message_label.text = "Username already taken"
			_:
				message_label.text = Talo.player_auth.last_error.get_string()
	else:
		_on_auth_success()

func _on_auth_success():
	message_label.text = "Login successful!"
	
	# Hide auth UI and show difficulty selection
	auth_container.hide()
	difficulty_container.show()
	challenging.grab_focus()

# Rest of your methods remain the same...

func start_game(speed: int):
	AudioManager.click.play()
	GameSettings.enemy_speed = speed
	animation_player.play("intro")
	
	var main_scene = load("res://scenes/main.tscn").instantiate()
	get_parent().add_child(main_scene)
	await animation_player.animation_finished
	AudioManager.background_music.play()
	queue_free()

func playVoice():
	AudioManager.hypertype_voice.play()

func playHit():
	AudioManager.cinematic_hit.play()
