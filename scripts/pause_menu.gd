extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var continue_btn: FancyButton = $ColorRect/VBoxContainer/Continue
@onready var restart_btn: FancyButton = $ColorRect/VBoxContainer/Restart
@onready var return_to_main_menu_btn: FancyButton = $ColorRect/VBoxContainer/ReturnToMainMenu

@onready var buttons: Array = [$ColorRect/VBoxContainer/Continue, 
							   $ColorRect/VBoxContainer/Restart,
							   $ColorRect/VBoxContainer/ReturnToMainMenu]


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
	restart_btn.pressed.connect(_on_restart_pressed)
	return_to_main_menu_btn.pressed.connect(_on_return_to_main_menu_pressed)
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

func _on_return_to_main_menu_pressed() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	GameSettings.clear_god_mode()
	var tree := get_tree()
	var root := tree.root
	var main_scene := root.get_node_or_null("Main")
	if main_scene and tree.current_scene != main_scene:
		var intro_scene: Node = load("res://scenes/intro_screen.tscn").instantiate()
		root.add_child(intro_scene)
		tree.current_scene = intro_scene
		main_scene.queue_free()
		tree.paused = false
		queue_free()
		return
	tree.paused = false
	tree.change_scene_to_file("res://scenes/intro_screen.tscn")

func _on_restart_pressed() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	GameSettings.clear_god_mode()
	var tree := get_tree()
	var root := tree.root
	var current_main := root.get_node_or_null("Main")
	if current_main == null:
		return

	var new_main_scene: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(new_main_scene)
	tree.current_scene = new_main_scene
	tree.paused = false
	current_main.queue_free()

	if new_main_scene.has_method("warm_up_gpu"):
		await new_main_scene.warm_up_gpu()
	
func playVoice():
	AudioManager.hypertype_voice.play()
	
func playHit():
	AudioManager.cinematic_hit.play()
	
func _input(event: InputEvent) -> void:

	if event.is_action_pressed("ui_cancel"):  # ESC key
		resume_game()
