extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var beginner: FancyButton = $ColorRect/VBoxContainer/Beginner
@onready var casual: FancyButton = $ColorRect/VBoxContainer/Casual
@onready var challenging: FancyButton = $ColorRect/VBoxContainer/Challenging
@onready var expert: FancyButton = $ColorRect/VBoxContainer/Expert
@onready var pro: FancyButton = $ColorRect/VBoxContainer/Pro
@onready var insane: FancyButton = $ColorRect/VBoxContainer/Insane

# Preload all enemy scenes
var enemy_scene = preload("res://scenes/enemy.tscn")
var tank_enemy_scene = preload("res://scenes/tank_enemy.tscn")
var small_enemy_scene = preload("res://scenes/small_enemy.tscn")
var robot_enemy_scene = preload("res://scenes/robot_enemy.tscn")
var ship_enemy_scene = preload("res://scenes/ship_enemy.tscn")

# Keep track of warmed up enemies
var warmed_up_enemies = {}
var warmup_container: Node2D

func _ready():
	# Connect the pressed signals for starting the game
	beginner.pressed.connect(func(): start_game(40))
	casual.pressed.connect(func(): start_game(100))
	challenging.pressed.connect(func(): start_game(190))
	expert.pressed.connect(func(): start_game(240))
	pro.pressed.connect(func(): start_game(310))
	insane.pressed.connect(func(): start_game(400))
	
	challenging.grab_focus()
	
	# Start warming up particles in the background
	warmup_container = Node2D.new()
	warmup_container.position = Vector2(-10000, -10000)  # Way off screen
	add_child(warmup_container)
	warm_up_enemy_types()

func warm_up_enemy_types():
	var enemy_scenes = {
		"basic": enemy_scene,
		"tank": tank_enemy_scene,
		"small": small_enemy_scene,
		"robot": robot_enemy_scene,
		"ship": ship_enemy_scene
	}
	
	# Start the warm-up process for each enemy type
	for enemy_type in enemy_scenes:
		warm_up_enemy(enemy_type, enemy_scenes[enemy_type])

func warm_up_enemy(type: String, scene: PackedScene):
	var enemy = scene.instantiate()
	warmup_container.add_child(enemy)
	
	# If the enemy has particles, warm them up
	if enemy.has_node("StepParticles"):
		var step_particles = enemy.get_node("StepParticles")
		step_particles.visible = false
		step_particles.emitting = true
		step_particles.speed_scale = 10.0
	
	if enemy.has_node("DieParticles"):
		var die_particles = enemy.get_node("DieParticles")
		die_particles.visible = false
		die_particles.emitting = true
		die_particles.speed_scale = 10.0
		
	if enemy.has_node("PointLight2D"):
		var point_light = enemy.get_node("PointLight2D")
		point_light.enabled = true
		
		# Create and execute the scaling tween
		var tween = create_tween()
		tween.tween_property(point_light, "scale", Vector2(0.1, 0.1), 0.1).set_trans(Tween.TRANS_LINEAR)
		await tween.finished
		point_light.enabled = false
	
	# Store the warmed up enemy
	warmed_up_enemies[type] = enemy

func start_game(speed: int):
	AudioManager.click.play()
	GameSettings.enemy_speed = speed
	animation_player.play("intro")
	
	# Instance the main scene
	var main_scene = load("res://scenes/main.tscn").instantiate()
	
	# Move our warmed up enemies to the main scene
	if is_instance_valid(warmup_container):
		for enemy in warmed_up_enemies.values():
			if is_instance_valid(enemy):
				# Reset particle states
				if enemy.has_node("StepParticles"):
					var step_particles = enemy.get_node("StepParticles")
					step_particles.emitting = false
					step_particles.speed_scale = 1.0
					step_particles.visible = true
				
				if enemy.has_node("DieParticles"):
					var die_particles = enemy.get_node("DieParticles")
					die_particles.emitting = false
					die_particles.speed_scale = 1.0
					die_particles.visible = true
		
		# Clean up the warmup container
		warmup_container.queue_free()
	
	get_parent().add_child(main_scene)
	await animation_player.animation_finished
	AudioManager.background_music.play()
	queue_free()

func playVoice():
	AudioManager.hypertype_voice.play()

func playHit():
	AudioManager.cinematic_hit.play()
