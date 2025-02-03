extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var beginner: Button = $ColorRect/VBoxContainer/Beginner
@onready var casual: Button = $ColorRect/VBoxContainer/Casual
@onready var challenging: Button = $ColorRect/VBoxContainer/Challenging
@onready var expert: Button = $ColorRect/VBoxContainer/Expert
@onready var insane: Button = $ColorRect/VBoxContainer/Insane

@onready var buttons: Array = [$ColorRect/VBoxContainer/Beginner, 
							   $ColorRect/VBoxContainer/Casual, 
							   $ColorRect/VBoxContainer/Challenging, 
							   $ColorRect/VBoxContainer/Expert, 
							   $ColorRect/VBoxContainer/Insane]


func _on_button_mouse_entered():
	AudioManager.ui_hover.pitch_scale = randf_range(0.9, 1.1)
	AudioManager.ui_hover.play()

func _ready():
	beginner.pressed.connect(func(): start_game(30))
	casual.pressed.connect(func(): start_game(80))        
	challenging.pressed.connect(func(): start_game(180)) 
	expert.pressed.connect(func(): start_game(230))
	insane.pressed.connect(func(): start_game(400))
	for button in buttons:
		button.mouse_entered.connect(_on_button_mouse_entered)

func start_game(speed: int):
	AudioManager.click.play()
	GameSettings.enemy_speed = speed
	animation_player.play("intro")
	var main_scene = load("res://scenes/main.tscn").instantiate()
	get_parent().add_child(main_scene)
	await animation_player.animation_finished
	AudioManager.background_music.play()
	queue_free()
