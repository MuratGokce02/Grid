extends TileMap

var map_size = Vector2(20, 20)
var half_cell_size = get_cell_size() / 2

var map = []
var full_cells = []


#func find_full_cells():
#	for x in range(map_size.x):
#		for y in range(map_size.y):
#			if map[x][y] != null:
#				for entity in full_cells:
#					if entity[0] == x and entity[1] == y:
#						return
#				full_cells.append([x, y])


func _ready():
	for x in range(map_size.x):
		map.append([])
		for y in range(map_size.y):
			map[x].append(null)
	full_cells.append([0, 0])


func _process(delta):
	pass


func _unhandled_input(event):
	if not event is InputEventMouseButton:
		return
	if event.pressed:
		var touch_position = event.get_position()
		#print(touch_position)
		var target_coordinates = world_to_map(touch_position)
		print(target_coordinates)
		if target_coordinates.x >= 20 or target_coordinates.y >= 20:
			return
		if is_target_cell_empty(target_coordinates):
			append_target(target_coordinates)


func is_target_cell_empty(target_coordinates):
	for entity in full_cells:
		if entity[0] == target_coordinates.x and entity[1] == target_coordinates.y:
			return false 
	return true


func append_target(target_coordinates):
	for entity in full_cells:
		if entity[0] == target_coordinates.x and entity[1] == target_coordinates.y:
			return
	map[target_coordinates.x][target_coordinates.y] = 5
	full_cells.append([target_coordinates.x, target_coordinates.y])
