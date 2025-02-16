# tank_enemy.gd
extends "res://scripts/enemy.gd"

func _after_ready():
	light_scale = Vector2(20, 10)

func setup_word():
	var words = word.split("\n")
	var spacing_x = 44
	var spacing_y = 60  # Vertical spacing between words
	
	var max_word_length = 0
	for w in words:
		max_word_length = max(max_word_length, w.length())
	
	var start_y = -400 - ((words.size() - 1) * spacing_y / 2)
	
	for word_index in words.size():
		var current_word = words[word_index]
		var start_x = -current_word.length() * spacing_x / 2
		
		for i in current_word.length():
			var letter_instance = letter_scene.instantiate()
			letter_instance.position.x = start_x + i * spacing_x
			letter_instance.position.y = start_y + word_index * spacing_y
			letter_instance.setup(current_word[i])
			letter_container.add_child(letter_instance)
			letter_scenes.append(letter_instance)
			current_letters.append(current_word[i])
			
			var letter_endpoint = letter_instance.position + letter_line_offset
			var direction = (letter_endpoint - enemy_line_offset).normalized()
			var line_start = enemy_line_offset + direction * line_start_extra_offset
			
			var line = Line2D.new()
			line.set_end_cap_mode(Line2D.LINE_CAP_ROUND)
			line.set_begin_cap_mode(Line2D.LINE_CAP_ROUND)
			line.add_point(line_start)
			line.add_point(letter_endpoint)
			line.width = 3.0
			line.default_color = Color(1, 1, 1, 0)
			letter_container.add_child(line)
			letter_lines.append(line)
