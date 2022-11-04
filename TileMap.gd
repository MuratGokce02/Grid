extends TileMap

enum{PLAYER}

export var map_size = Vector2(20, 20)
var half_cell_size = get_cell_size() / 2

var map = []
var full_cells = []
var walkable_cells = []

var player_coordinates = Vector2(10, 10)
var player_selected = false
var battle_mode = false
var player_speed = 4


func _ready():
	for x in range(map_size.x):
		map.append([])
		for y in range(map_size.y):
			map[x].append(null)
	map[player_coordinates.x][player_coordinates.y] = 5


func _process(delta):
	is_player_selected()


func _unhandled_input(event):
	if not event is InputEventMouseButton:
		return
	if event.pressed:
		var touch_position = event.get_position()
		print(touch_position)
		var target_coordinates = world_to_map(touch_position)
		print(target_coordinates)
		if target_coordinates == player_coordinates:
			player_selected = true
			print("player selected")
			return
		if target_coordinates.x >= map_size.x or target_coordinates.y >= map_size.y:
			return
		if is_target_cell_empty(target_coordinates):
			print("target appended")
			append_target(target_coordinates)


func is_target_cell_empty(target_coordinates):
	for entity in full_cells:
		if entity[0] == target_coordinates.x and entity[1] == target_coordinates.y:
			return false 
	return true


func append_target(target_coordinates):
	if not full_cells.size() == 0:
		for entity in full_cells:
			if entity[0] == target_coordinates.x and entity[1] == target_coordinates.y:
				return
		map[target_coordinates.x][target_coordinates.y] = 5
		full_cells.append([target_coordinates.x, target_coordinates.y])


func find_walkable_cells():
	var directions = {"up": Vector2(0, -1), "rigth": Vector2(1, 0), "down": Vector2(0, -1), "left": Vector2(-1, 0)}	
	var length = player_speed
	var current = player_coordinates
	walkable_cells.append(player_coordinates)
	for i in range(length, 0, 0):
		walkable_cells.append(current + directions.up)
#		current += directions.right
#		walkable_cells.append(current)



func is_player_selected():
	if player_selected == true:
		find_walkable_cells()
		print(walkable_cells)


