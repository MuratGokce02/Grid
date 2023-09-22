extends TileMap


#Game variables
var paused = true
var chosen
var walking
var characters_list = []#["character id", "ticks until move", "character path"]]
var moves_list = []
var characters_list_2 = []
var character_template = {"node": null, "coordinates": null, "ticks": null, "path": []}


#Map variables
var map
var walkable_cells = []
var walkable_cells_coords_only = []
var highlight_nodes = []
var character_cells = []
var highlights_shown = false
var cell_offset = Vector2(-16, -20)
var camera
var astar_grid = AStar2D.new()


#Input variables
var drag = false
var drag_counter = 1


#Signals
signal ui_update
signal timer_stop

@onready var cell_highlight = preload("res://sources/scenes/map_scenes/highlight.tscn")
@onready var player = preload("res://sources/scenes/character_scenes/player.tscn")
@onready var skeleton = preload("res://sources/scenes/character_scenes/skeleton.tscn")


func _ready():
	map = get_used_cells(0)
	get_node("Playable").add_child(player.instantiate())
	get_node("Playable").add_child(skeleton.instantiate())
	get_node("Playable").add_child(skeleton.instantiate())
#	get_node("Playable").add_child(skeleton.instantiate())
	for character in get_node("Playable").get_children():
		var coordinate
		while coordinate not in map:
			coordinate = Vector2i(randi_range(0, 15), randi_range(0, 15))
		var character_instance = character_template.duplicate()
		character_instance.node = character
		character_instance.coordinates = coordinate
		character_instance.ticks = 4
		print(character_instance)
		characters_list.append(character_instance)
		#characters_list.append([character, 5, []])
		character.set_position(map_to_local(coordinate) + cell_offset)
		character_cells.append(coordinate)
		add_layer(get_layers_count())
		set_layer_name(get_layers_count() - 1, str(character))


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if drag and drag_counter == 0:
			drag = false
			drag_counter = 1
		elif drag:
			drag_counter -= 1
			if drag_counter < 0:
				drag_counter = 0
		#print(drag)
		if drag == false:
			if event.is_released() and event.button_index != MOUSE_BUTTON_WHEEL_UP and event.button_index != MOUSE_BUTTON_WHEEL_DOWN:
				var touch_position = camera.get_screen_center_position() + ( - get_viewport_rect().size / 2 + event.get_position()) / camera.get_zoom()
				var target_coordinates = local_to_map(touch_position)
				print(target_coordinates)
				if walking and chosen != null:
					walk(target_coordinates)
					return
				elif paused and target_coordinates in character_cells:
					for character in characters_list:
						if character.coordinates == target_coordinates:
							choose(character)
							break
		print(drag)
		#print(drag_counter)
	return


func currently_active():
	for character in characters_list:
		if character[2] == 0:
			return character


func choose(character):
	get_parent().get_node("UICanvas/SkillBar/WalkButton").disabled = false
	chosen = character
	chosen.node.get_child(3).play("Character Animations/Turn")
	print(chosen)


func walk_start():
	if paused and chosen != null:
		clear_walkable_cells()
		show_walkable_cells()
		for layer in get_layers_count():
			if get_layer_name(layer) == str(chosen.node):
				clear_layer(layer) 
		walking =  true


func walk(target_coordinates):
	astar_creator(chosen)
	var path_coordinates = []
	for coordinate in astar_grid.get_point_path(0, walkable_cells_coords_only.find(target_coordinates) + 1):
		@warning_ignore("narrowing_conversion")
		path_coordinates.append(Vector2i(coordinate.x, coordinate.y)) 
	if path_coordinates.size() > 1:
		for character in characters_list:
			if character == chosen:
				print(character.path.size())
				if not character.path.is_empty() and not character.path[0] == path_coordinates[0]:
					character.ticks = 10 - character.node.agility
				elif character.path.size() < 2:
					character.ticks = 10 - character.node.agility
				character.path = path_coordinates
	walking = false
	chosen.node.get_child(3).pause()
	emit_signal("ui_update")
	handle_map()
	clear_walkable_cells()


func pause():
	#print("lol")
	if paused:
		paused = false
		clear_walkable_cells()
		for character in characters_list:
			if character == chosen and not character.ticks == 0:
				chosen = null
				get_parent().get_node("UICanvas/SkillBar/WalkButton").disabled = true
				break
	else:
		paused = true


func game_runner():
	var character_turn = false
	for character in characters_list:
		if character.ticks == 0:
			character_turn = true
			choose(character)
			emit_signal("timer_stop")
			break
	if not character_turn:
		reduce_all_turn_timers(1)
	handle_map()
	#print("lol")


func handle_map():
	var future_data = characters_list.duplicate()
	var future_cells = character_cells.duplicate()
	for character in future_data:
		if character.ticks == 0 and not character.path.size() < 2:# character.path.size() > 2 and 
			if character.path[1] in future_cells:
				character.path.clear()
				choose(character)
				update_map()
				emit_signal("timer_stop")
				return
			future_cells.erase(character.coordinates)
			character.coordinates = character.path[1]
			future_cells.append(character.path[1])
			character.path.remove_at(0)
			if character.path.size() != 1:
				character.ticks = 10 - character.node.agility
	characters_list = future_data.duplicate()
	character_cells = future_cells.duplicate()
	update_map()


func update_map():
	var current_layer
	for character in characters_list:
		for layer in get_layers_count():
			if get_layer_name(layer) == str(character.node):
				current_layer = layer
		clear_layer(current_layer)
		set_cells_terrain_connect(current_layer, character.path, 0, 0)
		if character.path.size() != 0:
			character.node.set_position(map_to_local(character.path[0]) + cell_offset)
	#	for character in characters_list:
	#		for layer in get_layers_count():
	#			if get_layer_name(layer) == str(character.node):
	#				current_layer = layer
	#		set_cells_terrain_connect(current_layer, character.path, 0, 0)
	#		if character.ticks == 0:
	#			character.path.remove_at(0)
	#			clear_layer(current_layer)
	#			set_cells_terrain_connect(current_layer, character.path, 0, 0)
	#			if character.path.size() != 0:
	#				#if not character.path[0] in character_cells:
	#					character.node.position = map_to_local(character.path[0])
	#					character_cells.erase(character.coordinates)
	#					character.coordinates = character.path[0]
	#					character_cells.append(character.path[0])
	#					character.node.set_position(map_to_local(character.path[0]) + cell_offset)
	#					if character.path.size() != 1:
	#						character.ticks = 10 - character.node.agility
	#				#elif character.path[0] in character_cells:
	#				#	emit_signal("timer_stop")
	return


func astar_creator(character):
	astar_grid.add_point(0, character.coordinates)
	for cell in walkable_cells_coords_only:
		astar_grid.add_point(astar_grid.get_available_point_id(), cell, 10 - character.node.agility)
	var point_count = astar_grid.get_point_count()
	for id in range(point_count):
		var center_position = astar_grid.get_point_position(id)
		for id2 in range(point_count):
			@warning_ignore("narrowing_conversion")
			var id2_position = Vector2i(astar_grid.get_point_position(id2).x, astar_grid.get_point_position(id2).y)
			if id2_position in get_surrounding_cells(center_position) and id2_position in walkable_cells_coords_only:
				if not astar_grid.are_points_connected(id2, id):
					astar_grid.connect_points(id, id2)


func show_walkable_cells():
	if highlights_shown == false:
		find_walkable_cells(chosen)
		show_walkable_cells_helper(walkable_cells)
		highlights_shown = true

func clear_walkable_cells():
	walkable_cells.clear()
	walkable_cells_coords_only.clear()
	astar_grid.clear()
	for node in highlight_nodes:
		node.queue_free()
	highlight_nodes.clear()
	clear_layer(1)
	highlights_shown = false
	handle_map()


func find_walkable_cells(character):
	var current = character.coordinates
	var rounds = character.node.agility
	var queue = [[current, 0]]
	var addible
	while not queue.is_empty():
		addible = true
		var at = queue.pop_front()
		if at[1] == rounds:
			break
		#if not at[0] in character_cells:
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
			if not surrounding in walkable_cells_coords_only and surrounding in map:#and not surrounding in character_cells 
					queue.append([surrounding, at[1] + 1])
	queue.clear()

func show_walkable_cells_helper(cells):
	for cell in cells:
		var highlight_node = cell_highlight.instantiate()
		highlight_node.get_child(0).text = var_to_str(cell[1] * (10 - chosen.node.agility))#var_to_str((distance.x + distance.y) * (10 - currently_active().agility))
		add_child(highlight_node)
		highlight_node.set_position(map_to_local(cell[0]))
		highlight_nodes.append(highlight_node)
		set_cells_terrain_connect(1, [cell[0]], 1, 0)


func reduce_all_turn_timers(time):
	for character in characters_list:
		if character.ticks > 0:
			character.ticks -= time
	emit_signal("ui_update")
