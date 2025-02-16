extends "res://scripts/enemy.gd"
@onready var small_step_particles: GPUParticles2D = $StepParticles

func _after_ready():
	light_scale = Vector2(1, 1)
	
func _physics_process(_delta):
	velocity.x = -speed
	move_and_slide()
	
	if small_step_particles and animated_sprite:
		var current_frame = animated_sprite.frame
		if current_frame != last_frame:
			if current_frame == 8:
				# Frame 1: Create duplicate of original particle system
				var new_original = small_step_particles.duplicate()
				add_child(new_original)
				new_original.emitting = true
				
				# Clean up after emission
				await get_tree().create_timer(0.3).timeout
				new_original.queue_free()
				
			elif current_frame == 3:
				# Frame 3: Create duplicate for background particles
				var new_back_particles = small_step_particles.duplicate()
				add_child(new_back_particles)
				new_back_particles.z_index = 0
				new_back_particles.emitting = true
				
				# Clean up after emission
				await get_tree().create_timer(0.3).timeout
				new_back_particles.queue_free()
		
		last_frame = current_frame
