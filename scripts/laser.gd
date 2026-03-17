extends Node2D

@export var projectile_speed: float = 5000.0  # Adjust speed as needed
@export var frame_duration: float = 0.05  # Duration for each animation frame

# Reference to your sprite sheet
var sprite: AnimatedSprite2D
var target_pos: Vector2
var velocity: Vector2
static var cached_frames: SpriteFrames

func _ready():
	# Create and setup the animated sprite
	sprite = AnimatedSprite2D.new()
	add_child(sprite)
	
	sprite.scale = Vector2(1, 3)
	if cached_frames == null:
		cached_frames = SpriteFrames.new()
		cached_frames.add_animation("default")
		
		# Load your sprite sheet
		var texture := load("res://assets/sprites/explosions/projectile.png") as Texture2D
		
		# Create AtlasTexture for each frame
		var frame_width := texture.get_width() / 2.0  # Divide by 2 since you have 2 frames
		var frame_height := texture.get_height()
		
		for i in range(2):
			var atlas := AtlasTexture.new()
			atlas.atlas = texture
			atlas.region = Rect2(i * frame_width, 0, frame_width, frame_height)
			cached_frames.add_frame("default", atlas)
	
	sprite.sprite_frames = cached_frames
	sprite.play("default")
	sprite.speed_scale = 1.0 / frame_duration

func shoot(start_pos: Vector2, end_pos: Vector2):
	position = start_pos
	target_pos = end_pos
	velocity = (target_pos - start_pos) / (5 * frame_duration)
	
	sprite.rotation = velocity.angle() + PI/2  
	
	var tween = create_tween()
	tween.tween_property(self, "position", target_pos, 2 * frame_duration)
	
	
	await tween.finished
	
	queue_free()
