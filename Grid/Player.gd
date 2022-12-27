extends Attributes
class_name Player


var map = get_parent()
var coordinates = Vector2(1, 1)


func _ready():
	set_position(map.map_to_world(coordinates))
	map.map[coordinates.x][coordinates.y] = 7

