extends Node

var loading_screen = preload("res://scenes/loading_screen.tscn")
var scene_location : String = "res://scenes/menu/main_menu.tscn"

func load_scene(location : String):
	scene_location = location
	get_tree().change_scene_to_packed(loading_screen)
