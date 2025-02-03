# player.gd
extends CharacterBody2D

signal shoot_laser(start_pos: Vector2, target_pos: Vector2)
signal player_hit

@onready var animated_sprite = $AnimatedSprite2D
@onready var laser_origin = $LaserOrigin
@onready var hurt_box: Area2D = $HurtBox
@onready var hit: AnimatedSprite2D = $Hit

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	animated_sprite.play("idle")
	hurt_box.area_entered.connect(_on_hurt_box_area_entered)

func _physics_process(delta):
	# Add the gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0  # Reset vertical velocity when on floor
	
	move_and_slide()
	
func take_damage() -> void:
	animated_sprite.play("wrong_letter")
	hit.show()
	hit.play()
	await animated_sprite.animation_finished
	hit.hide()
	animated_sprite.play("idle")

func shoot(target_pos: Vector2):
	animated_sprite.play("shooting")
	shoot_laser.emit(laser_origin.global_position, target_pos)
	await animated_sprite.animation_finished
	animated_sprite.play("idle")
	
func _on_hurt_box_area_entered(area: Area2D):
	print(area)
	if area.is_in_group("enemy_hitbox"):
		player_hit.emit()

func die():
	hurt_box.queue_free()
	animated_sprite.play("die")
	await animated_sprite.animation_finished
	queue_free()
