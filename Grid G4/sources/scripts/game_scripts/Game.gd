extends Node


func _ready():
	find_child("TileMap").camera = find_child("Camera")
	#find_child("Camera").position = find_child("TileMap").chosen.position
