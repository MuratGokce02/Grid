extends HBoxContainer


var current_skills
var tilemap


func get_skills():
	return 


func list_skills():
	for skill in current_skills:
		var skill_block = load("res://sources/scenes/ui_scenes/spriteandlabel.tscn").instantiate()
		add_child(skill_block)


func _on_game_ready():
	tilemap = get_node("/root/Game/TileMap")
	current_skills = tilemap.currently_active().skills
	list_skills()
	pass # Replace with function body.
