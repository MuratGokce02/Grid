extends TileMap

var map_size = Vector2(20, 20)
var half_cell_size = get_cell_size() / 2

var map = []
var filled_cells = []

func find_filled_cells():
	for x in range(map_size.x):
		for y in range(map_size.y):
			if map[x][y] != null:
				filled_cells.append([x, y])

func _unhandled_input(touch):
	if not touch is InputEventScreenTouch:
		return
	if touch.pressed:
		var touch_position = touch.get_position()
		var target_coordinates = touch_position.world_to_map()
		if is_target_cell_empty(touch_position):
			map[target_coordinates.x][target_coordinates.y] = 5

func is_target_cell_empty(target):
	var target_pos = target.world_to_map()
	if filled_cells.has([target_pos.x, target_pos.y]):
		return false 
	else:
		return true
	
func append_target():
	pass

func _ready():
	for x in range(map_size.x):
		map.append([])
		for y in range(map_size.y):
			map[x].append(null)
			
func _process(delta):
	map[4][4] = 5
	find_filled_cells()
	print(filled_cells)
