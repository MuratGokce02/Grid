extends Camera2D


var single_touch
var second_touch
var previous_event
var zoom_event = false


func _unhandled_input(event):
	if event is InputEventScreenDrag:
		if event.index == 0:
			single_touch = event
		if event.index == 1:
			second_touch = event
			zoom_event = true
		if previous_event == null or event.index == previous_event.index:
			zoom_event = false
		previous_event = event
		if zoom_event == false:
			if get_screen_center_position().x - get_viewport_rect().size.x / 2 / zoom.x - event.relative.x >= 0:
				position.x = (position.x - event.relative.x / zoom.x)
			if get_screen_center_position().y - get_viewport_rect().size.y / 2 / zoom.y - event.relative.y >= 0:
				position.y = (position.y - event.relative.y / zoom.x)
		if zoom_event == true:
			var zoom_value
			var zoom_x
			var zoom_y
			if single_touch.position.x <  second_touch.position.x:
				zoom_x = second_touch.relative.x - single_touch.relative.x
				if single_touch.position.y > second_touch.position.y:
					zoom_y = single_touch.relative.y - second_touch.relative.y
				else:
					zoom_y = second_touch.relative.y - single_touch.relative.y
			else:
				zoom_x = single_touch.relative.x - second_touch.relative.x
				if single_touch.position.y > second_touch.position.y:
					zoom_y = single_touch.relative.y - second_touch.relative.y
				else:
					zoom_y = second_touch.relative.y - single_touch.relative.y
			zoom_value = Vector2(0.01, 0.01) * (zoom_x - zoom_y * 0.5625)
			if not zoom.x + zoom_value.x < 0.5 and not zoom.x + zoom_value.x > 2:
				zoom = zoom + zoom_value
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if zoom.x + 0.03 < 2:
				zoom += Vector2(0.03, 0.03)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if zoom.x - 0.03 > 0.5:
				zoom -= Vector2(0.03, 0.03)
	get_parent().find_child("TileMap").drag = false
	return


func save(content):
	var file = FileAccess.open("res://save_game.txt", FileAccess.WRITE)
	file.store_string(content)
	return
