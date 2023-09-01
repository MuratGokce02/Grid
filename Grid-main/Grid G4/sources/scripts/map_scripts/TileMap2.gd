extends TileMap

var cell_offset = Vector2(-16, -20)
var astar_grid = AStar2D.new()
var characters_list = [["character id", "ticks until move", "character path"]]
var character_cells = []
var moves_list = []
var walkable_cells_coords_only = []


@onready var player = preload("res://sources/scenes/character_scenes/player.tscn")
@onready var skeleton = preload("res://sources/scenes/character_scenes/skeleton.tscn")


func _ready():
	get_node("Playable").add_child(player.instantiate())
	get_node("Playable").add_child(skeleton.instantiate())
	get_node("Playable").add_child(skeleton.instantiate())
	for character in get_node("Playable").get_children():
		characters_list.append([character, 0, null])
		character.set_position(map_to_local(character.coordinates) + cell_offset)
		character_cells.append(character.coordinates)
		add_layer(get_layers_count())
		set_layer_name(get_layers_count(), str(character))


func currently_active():
	for character in characters_list:
		if character[2] == 0:
			return character


func game_runner():
	var tick_runout = false
	for character in characters_list:
		var ticks_left = character[1]
		if character[1] == 0:
			moves_list.append([character, character[2][0]])
			character[2][0].remove_at(0)
			tick_runout = true
			update_map()
		if ticks_left != 0 and tick_runout == false:
			character[1] -= 1
	return


func update_map():
	var current_layer
	for move in moves_list:
		for layer in get_layers_count():
			if get_layer_name(layer) == move[0]:
				current_layer = layer
		move[0].position = map_to_local(move[1])
		erase_cell(current_layer, move[1])
	moves_list.clear()
	return


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
