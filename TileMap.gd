extends TileMap

enum{PLAYER}

export var map_size = Vector2(20, 20)
var half_cell_size = get_cell_size() / 2
var directions = {"up": Vector2(0, -1), "rigth": Vector2(1, 0), "down": Vector2(0, 1), "left": Vector2(-1, 0)}

var map = []
var full_cells = []
var walkable_cells = []
var character_cells = [Vector2(8, 8)]
var highlight_nodes = []

var character_turn_list = []

var player_coordinates = Vector2(5, 5)
var player_selected = false
var battle_mode = false
var player_speed = 5

var cell_highlight = preload("res://cell_highlight.png")

func _ready():
	for y in range(map_size.x):
		map.append([])
		for _x in range(map_size.y):
			map[y].append(1)
	map[player_coordinates.x][player_coordinates.y] = 7


func _process(delta):
	pass


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			#for y in map:
				#print(y)
			var touch_position = event.get_position()
			print(touch_position)
			var target_coordinates = world_to_map(touch_position)
			print(target_coordinates)
			if target_coordinates == player_coordinates:
				player_selected = true
				is_player_selected()
				print("player selected")
				return
			if player_selected == true:
				if character_cells.has(target_coordinates):
					print("hug")
				else:
					var moved = move_character(player_coordinates, target_coordinates, player_speed)
					if moved:
						print("player moving")
						player_coordinates = target_coordinates
						player_selected = false
						for y in map:
							print(y)
						for node in highlight_nodes:
							remove_child(node)
						highlight_nodes.clear()
						print("player moved")
						return
					else:
						print("player haven't moved")
						return
			if target_coordinates.x >= map_size.x or target_coordinates.y >= map_size.y:
				return
			if is_target_cell_empty(target_coordinates):
				print("target appended")
				append_target(target_coordinates)
	if not event is InputEventMouseButton:
		return


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


func find_walkable_cells(var character_coordinates, var speed):
	var current = character_coordinates
	for i in range(speed, -1, -1):
		find_walkable_cells_helper(current + i * directions.left, speed - i + 1)
		find_walkable_cells_helper(current + directions.rigth + i * directions.rigth, speed - i)
	for cell in character_cells:
		if walkable_cells.has(cell):
			walkable_cells.erase(cell)
	print(walkable_cells)


func find_walkable_cells_helper(var current, var length):
	for i in range(length):
		var up = current + directions.up * i
		if not up.x < 0 and not up.y < 0 and not up.x >= map_size.x and not up.y >= map_size.y:
			walkable_cells.append(up)
		if i != 0:
			var down = current + directions.down * i
			if not down.x < 0 and not down.y < 0 and not down.x >= map_size.x and not down.y >= map_size.y:
				walkable_cells.append(down)


func show_walkable_cells(var cells):
	for cell in cells:
		var highlight_node = Sprite.new()
		add_child(highlight_node)
		highlight_node.set_position(map_to_world(cell) + half_cell_size)
		highlight_node.set_texture(cell_highlight)
		highlight_nodes.append(highlight_node)


func move_character(var character_coordinates, var target_coordinates, var speed):
	find_walkable_cells(character_coordinates, speed)
	if walkable_cells.has(target_coordinates):
		if not full_cells.has(target_coordinates):
			map[target_coordinates.y][target_coordinates.x] = map[character_coordinates.y][character_coordinates.x]
			map[character_coordinates.y][character_coordinates.x] = 1
			walkable_cells.clear()
			return true
		walkable_cells.clear()
		print("cell is full")
		return false
	walkable_cells.clear()
	return false


func is_player_selected():
	if player_selected == true:
		find_walkable_cells(player_coordinates, player_speed)
		show_walkable_cells(walkable_cells)
		walkable_cells.clear()
		
func add_to_turn_list(var character, var action):
	if not character_turn_list.empty:
		for x in character_turn_list:
			if x[1] < action.time:
				character_turn_list.insert(character_turn_list.find(x) + 1, [character, action.time])
		
		
#func lol():
	#var harita = []
	#for x in range(20):
	#	harita.append([])
	#	for y in range(20):
	#		harita[x].append(0)

	#for cell in walkable_cells:
	#	harita[cell.y][cell.x] = "1"

	#for y in harita:
	#	print(y)



