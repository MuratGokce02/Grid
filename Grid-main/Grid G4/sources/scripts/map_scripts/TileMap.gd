class_name MapClass extends TileMap


var directions = {"up": Vector2i(0, -1), "rigth": Vector2i(1, 0), "down": Vector2i(0, 1), "left": Vector2i(-1, 0)}


var map = []
var full_cells = []
var walkable_cells = []
var walkable_cells_coords_only = []
var character_cells = []
var highlight_nodes = []
var characters = []
var moves = []
var astar_grid = AStar2D.new()
var highlights_shown = false
var cell_offset = Vector2(-16, -20)
var drag = false
var camera
var mouse_highlight
var turn


signal ui_update
signal started
signal stopped

var character_turn_list = []

@onready var cell_highlight = preload("res://sources/scenes/map_scenes/highlight.tscn")
@onready var turn_highlight = preload("res://sources/scenes/map_scenes/turn_highlight.tscn")
@onready var enemy = preload("res://icon.svg")
@onready var player = preload("res://sources/scenes/character_scenes/player.tscn")
@onready var skeleton = preload("res://sources/scenes/character_scenes/skeleton.tscn")
#@onready var skills = preload("res://sources/scripts/character_scripts/Skills.gd").instantiate()


func _ready():
	map = get_used_cells(0)
	get_node("Playable").add_child(player.instantiate())
	get_node("Playable").add_child(skeleton.instantiate())
	get_node("Playable").add_child(skeleton.instantiate())
	characters = get_node("Playable").get_children()
	for character in characters:
		add_to_turn_list(character, 0)
		reduce_all_turn_timers(0)
		character.set_position(map_to_local(character.coordinates) + cell_offset)
		character_cells.append(character.coordinates)
		moves.append([character, 10 - character.agility, null])
	mouse_highlight = cell_highlight.instantiate()
	add_child(mouse_highlight)
	turn = turn_highlight.instantiate()
	add_child(turn)



func _process(_delta):
	mouse_highlight.set_position(map_to_local(local_to_map(get_global_mouse_position())))
	#set_cell(1, local_to_map(get_global_mouse_position()), 0, Vector2i(0, 0))


func _unhandled_input(event):
	if event is InputEventMouseButton and drag == false:
		if event.is_released() and event.button_index != MOUSE_BUTTON_WHEEL_UP and event.button_index != MOUSE_BUTTON_WHEEL_DOWN:
			if highlights_shown:
				var touch_position = camera.get_screen_center_position() + ( - get_viewport_rect().size / 2 + event.get_position()) / camera.get_zoom()
				var target_coordinates = local_to_map(touch_position)
				move_character(currently_active(), target_coordinates)
	drag = false
	return


func game_timer():
	if character_turn_list[0][1] != 0:
		for move in range(moves.size()):
			if moves[move][2] != null:
				moves[move][1] -= 1
				set_cells_terrain_connect(1, moves[move][2], 0, 0)
				var character = moves[move][0]
				if moves[move][1] == 0:
					character_cells.erase(character.coordinates)
					character.coordinates = moves[move][2][1]
					character_cells.append(moves[move][2][1])
					character.set_position(map_to_local(moves[move][2][1]) + cell_offset)
					erase_cell(1, moves[move][2][0])
					moves[move][2].remove_at(0)
					moves[move][1] = 10 - character.agility
		reduce_all_turn_timers(1)
		emit_signal("started")
	else:
		turn.position = map_to_local(currently_active().coordinates)
		currently_active().get_child(3).play("Character Animations/Turn")
		emit_signal("stopped")


func currently_active():
	return character_turn_list[0][0]


func append_target(target_coordinates):
	if not full_cells.size() == 0:
		for entity in full_cells:
			if entity[0] == target_coordinates.x and entity[1] == target_coordinates.y:
				return
		full_cells.append([target_coordinates.x, target_coordinates.y])


func show_walkable_cells():
	if highlights_shown == false:
		find_walkable_cells(currently_active())
		show_walkable_cells_helper(walkable_cells)
		highlights_shown = true

func find_walkable_cells(character):
	var current = character.coordinates
	var rounds = character.agility
	var queue = [[current, 0]]
	var addible
	while not queue.is_empty():
		addible = true
		var at = queue.pop_front()
		if at[1] == rounds:
			break
		if not at[0] in character_cells:
			for cell in walkable_cells:
				if at[0] == cell[0]:
					addible = false
					break
			if addible == true:
				walkable_cells.append(at)
		for surrounding in get_surrounding_cells(at[0]):
			walkable_cells_coords_only.clear()
			for cell in walkable_cells:
				walkable_cells_coords_only.append(cell[0])
			if not surrounding in walkable_cells_coords_only and not surrounding in character_cells and surrounding in map:
					queue.append([surrounding, at[1] + 1])
	queue.clear()

func show_walkable_cells_helper(cells):
	for cell in cells:
		var highlight_node = cell_highlight.instantiate()
		highlight_node.get_child(0).text = var_to_str(cell[1] * (10 - currently_active().agility))#var_to_str((distance.x + distance.y) * (10 - currently_active().agility))
		add_child(highlight_node)
		highlight_node.set_position(map_to_local(cell[0]))
		highlight_nodes.append(highlight_node)


func move_character(character, target_coordinates):
	astar_creator(character)
	if walkable_cells_coords_only.has(target_coordinates):
		var path_coordinates = astar_grid.get_point_path(0, walkable_cells_coords_only.find(target_coordinates) + 1)
		for move in range(moves.size()):
			if moves[move][0] == character:
				moves[move][2] = path_coordinates
		var time = walkable_cells[walkable_cells_coords_only.find(target_coordinates)][1] * (10 - character.agility)
		handle_turn_list(character, time)
		for highlight in highlight_nodes:
			highlight.queue_free()
		character.get_child(3).pause()
		turn.position = Vector2(-100, -100)
		highlights_shown = false
		walkable_cells.clear()
		walkable_cells_coords_only.clear()
		highlight_nodes.clear()
		astar_grid.clear()


func astar_creator(character):
	astar_grid.add_point(0, character.coordinates)
	for cell in walkable_cells_coords_only:
		astar_grid.add_point(astar_grid.get_available_point_id(), cell, 10 - character.agility)
	var point_count = astar_grid.get_point_count()
	for id in range(point_count):
		var center_position = astar_grid.get_point_position(id)
		for id2 in range(point_count):
			@warning_ignore("narrowing_conversion")
			var id2_position = Vector2i(astar_grid.get_point_position(id2).x, astar_grid.get_point_position(id2).y)
			if id2_position in get_surrounding_cells(center_position) and id2_position in walkable_cells_coords_only:
				if not astar_grid.are_points_connected(id2, id):
					astar_grid.connect_points(id, id2)


func handle_turn_list(character, time):
	character_turn_list.remove_at(0)
	add_to_turn_list(character, time)

func add_to_turn_list(character, action):
	if character_turn_list.is_empty():
		character_turn_list.append([character, action])
	else:
		for x in character_turn_list:
			if x[1] >= action:
				character_turn_list.insert(character_turn_list.find(x), [character, action])
				return
		character_turn_list.append([character, action])

func reduce_all_turn_timers(time):
	for character in character_turn_list:
		character[1] -= time
	clamp_turn_list()
	emit_signal("ui_update")

func clamp_turn_list():
	if character_turn_list[0][1] < 0:
		reduce_all_turn_timers(character_turn_list[0][1])


func save(content):
	var file = FileAccess.open("res://save_game.txt", FileAccess.WRITE)
	file.store_string(content)
	return
