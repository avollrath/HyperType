extends Button
class_name FancyButton

@export var hover_scale: float = 1.1
@export var hover_rotation: float = 0.1  # degrees
@export var hover_time: float = 0.2

func _ready() -> void:
	# Center the pivot so animations occur about the center.
	pivot_offset = size / 2
	# Allow the button to receive keyboard focus.
	focus_mode = Control.FOCUS_ALL
	
	# Connect mouse and focus signals using the new callable syntax.
	self.mouse_entered.connect(Callable(self, "_on_mouse_entered"))
	self.mouse_exited.connect(Callable(self, "_on_mouse_exited"))
	self.focus_entered.connect(Callable(self, "_on_focus_entered"))
	self.focus_exited.connect(Callable(self, "_on_focus_exited"))

# --- Tween management ---
func _kill_active_tween() -> void:
	if has_meta("hover_tween"):
		var tween = get_meta("hover_tween")
		if tween:
			tween.kill()
		set_meta("hover_tween", null)

func _clear_tween() -> void:
	set_meta("hover_tween", null)

# --- Hover and Focus Effects ---
func _on_mouse_entered() -> void:
	_kill_active_tween()
	var tween = create_tween()
	set_meta("hover_tween", tween)
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(hover_scale, hover_scale), hover_time).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "rotation_degrees", hover_rotation, hover_time).set_trans(Tween.TRANS_BOUNCE)
	
	# Optional: apply a slight brightness increase.
	modulate = Color(1.6, 1.6, 1.6)
	
	# Play hover sound (make sure your AudioManager exists and is accessible).
	AudioManager.ui_hover.pitch_scale = randf_range(0.9, 1.1)
	AudioManager.ui_hover.play()
	
	# When the tween finishes, clear the stored reference.
	tween.finished.connect(Callable(self, "_clear_tween"))

func _on_mouse_exited() -> void:
	_kill_active_tween()
	rotation_degrees = 0
	modulate = Color.WHITE
	var tween = create_tween()
	set_meta("hover_tween", tween)
	tween.tween_property(self, "scale", Vector2.ONE, hover_time / 2).set_trans(Tween.TRANS_BACK)
	tween.finished.connect(Callable(self, "_clear_tween"))

func _on_focus_entered() -> void:
	# Reuse the mouse-entered effect when gaining focus.
	_on_mouse_entered()

func _on_focus_exited() -> void:
	# Reuse the mouse-exited effect when focus is lost.
	_on_mouse_exited()
	
