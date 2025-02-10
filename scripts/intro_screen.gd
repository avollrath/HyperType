extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var beginner: FancyButton = $ColorRect/VBoxContainer/Beginner
@onready var casual: FancyButton = $ColorRect/VBoxContainer/Casual
@onready var challenging: FancyButton = $ColorRect/VBoxContainer/Challenging
@onready var expert: FancyButton = $ColorRect/VBoxContainer/Expert
@onready var pro: FancyButton = $ColorRect/VBoxContainer/Pro
@onready var insane: FancyButton = $ColorRect/VBoxContainer/Insane

func _ready():
	# Connect the pressed signals for starting the game.
	beginner.pressed.connect(func(): start_game(40))
	casual.pressed.connect(func(): start_game(100))
	challenging.pressed.connect(func(): start_game(190))
	expert.pressed.connect(func(): start_game(240))
	pro.pressed.connect(func(): start_game(310))
	insane.pressed.connect(func(): start_game(400))
	
	challenging.grab_focus()

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
