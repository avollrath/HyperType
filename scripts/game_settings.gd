extends Node

var enemy_speed: int = 190  # Default speed
var god_mode_pending: bool = false
var god_mode_active: bool = false

func consume_god_mode() -> bool:
	god_mode_active = god_mode_pending
	god_mode_pending = false
	return god_mode_active

func clear_god_mode() -> void:
	god_mode_pending = false
	god_mode_active = false
