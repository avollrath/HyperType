extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var continue_btn: FancyButton = $ColorRect/VBoxContainer/Continue
@onready var settings_btn: FancyButton = $ColorRect/VBoxContainer/Settings
@onready var quit_btn: FancyButton = $ColorRect/VBoxContainer/Quit

@onready var buttons: Array = [$ColorRect/VBoxContainer/Continue, 
							   $ColorRect/VBoxContainer/Settings, 
							   $ColorRect/VBoxContainer/Quit]


func _on_button_mouse_entered(button_node: Button):
	var tween = create_tween()
	tween.tween_property(button_node, "scale", Vector2(1.1, 1.1), 0.1).set_trans(Tween.TRANS_LINEAR)
	AudioManager.ui_hover.pitch_scale = randf_range(0.9, 1.1)
	AudioManager.ui_hover.play()
	
func _on_button_mouse_exited(button_node: Button):
	var tween = create_tween()
	tween.tween_property(button_node, "scale", Vector2(1, 1), 0.05).set_trans(Tween.TRANS_LINEAR)

func _ready():
	animation_player.play("intro")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	continue_btn.pressed.connect(func(): resume_game())
	settings_btn.pressed.connect(func(): resume_game())
	quit_btn.pressed.connect(func(): get_tree().quit())
	for button in buttons:
		button.pivot_offset = button.size / 2
		button.mouse_entered.connect(_on_button_mouse_entered.bind(button))
		button.mouse_exited.connect(_on_button_mouse_exited.bind(button))
	continue_btn.grab_focus()

func resume_game():
	print('Button pressed')
	animation_player.play("Outro")
	await animation_player.animation_finished
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	queue_free()
	
func playVoice():
	AudioManager.hypertype_voice.play()
	
func playHit():
	AudioManager.cinematic_hit.play()
	
func _input(event: InputEvent) -> void:

	if event.is_action_pressed("ui_cancel"):  # ESC key
		resume_game()
