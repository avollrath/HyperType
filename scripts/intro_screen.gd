extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _input(event):
	if event is InputEventKey and event.pressed:
		animation_player.play("intro")
		var main_scene = load("res://scenes/main.tscn").instantiate()  # Load and instantiate main scene
		get_parent().add_child(main_scene)  #
		await animation_player.animation_finished
		queue_free()  # Remove the intro scene
