extends VBoxContainer


var character_list = []
var reverse_character_list = []
var tilemap


func list_skills():
	for character in character_list:
		var skill_block = load("res://sources/scenes/ui_scenes/spriteandlabel.tscn").instantiate()
		skill_block.get_child(0).texture_normal = character.node.get_child(0).texture
		skill_block.get_child(1).set_text("IDLE" if character.ticks == 0 and character.path.is_empty() else str(character.ticks) + "\n" + str((10 - character.node.agility) * ((character.path.size() if character.path.size() != 0 else 2) - 2) + character.ticks))#and character == character_list[character_list.size() - 1]
		add_child(skill_block)


func update():
	for child in get_children():
		remove_child(child)
	character_list.clear()
	tilemap = get_node("/root/Game/TileMap")
	for character in tilemap.characters_list:
		character_list.append(character)
	character_list.reverse()
	list_skills()

func reverse_list():
	for character in character_list:
		reverse_character_list.append(character)
		reverse_character_list.reverse()
