extends Node2D

@export var beam_color: Color = Color(1, 0, 0, 1)  # Default red
@export var beam_width: float = 4.0
@export var glow_width: float = 8.0
@export var core_width: float = 2.0

func shoot(start_pos: Vector2, target_pos: Vector2):
	position = start_pos
	var beam_vector = target_pos - start_pos
	
	# Create the outer glow (wide, semi-transparent)
	var glow_outer = Line2D.new()
	glow_outer.add_point(Vector2.ZERO)
	glow_outer.add_point(beam_vector)
	glow_outer.width = glow_width
	glow_outer.default_color = beam_color.lerp(Color.WHITE, 0.5)
	glow_outer.default_color.a = 0.3
	add_child(glow_outer)
	
	# Create the main beam
	var main_beam = Line2D.new()
	main_beam.add_point(Vector2.ZERO)
	main_beam.add_point(beam_vector)
	main_beam.width = beam_width
	main_beam.default_color = beam_color
	add_child(main_beam)
	
	# Create the inner core (bright white)
	var core_beam = Line2D.new()
	core_beam.add_point(Vector2.ZERO)
	core_beam.add_point(beam_vector)
	core_beam.width = core_width
	core_beam.default_color = beam_color.lerp(Color.WHITE, 0.8)
	add_child(core_beam)
	
	# Add a particle effect along the beam
	var particles = GPUParticles2D.new()
	var particle_material = ParticleProcessMaterial.new()
	

	
	particle_material.particle_flag_disable_z = true
	particle_material.direction = Vector3(0, 1, 0)
	particle_material.spread = 180.0  # Emit in all directions
	particle_material.gravity = Vector3.ZERO
	particle_material.initial_velocity_min = 20
	particle_material.initial_velocity_max = 40
	particle_material.scale_min = 0.1
	particle_material.scale_max = 0.3
	particle_material.color = beam_color
	
	particles.process_material = particle_material
	particles.amount = 500  # Increased amount to compensate for point emission
	particles.lifetime = 0.2
	particles.explosiveness = 0.0
	add_child(particles)
	
	# Create tween for fade out effect
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Fade out all components
	tween.tween_property(glow_outer, "modulate:a", 0.0, 0.2)
	tween.tween_property(main_beam, "modulate:a", 0.0, 0.2)
	tween.tween_property(core_beam, "modulate:a", 0.0, 0.2)
	tween.tween_property(particles, "modulate:a", 0.0, 0.2)
	
	# Optional: Add a quick "flash" at the start
	modulate = Color.WHITE
	tween.tween_property(self, "modulate", beam_color, 0.1)
	
	await tween.finished
	queue_free()
